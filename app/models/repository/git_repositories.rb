module Repository::GitRepositories
  extend ActiveSupport::Concern

  included do
    after_create  :git
    after_destroy :destroy_git
  end

  def git(reset=false)
    @git ||= GitRepository.new(local_path)
  end

  def git!
    @git = GitRepository.new(local_path)
  end

  def local_path
    "#{Ontohub::Application.config.git_root}/#{id}"
  end

  def local_path_working_copy
    "#{Ontohub::Application.config.git_working_copies_root}/#{id}"
  end

  def destroy_git
    FileUtils.rmtree local_path
    FileUtils.rmtree local_path_working_copy
  end

  def is_head?(commit_oid=nil)
    git.is_head?(commit_oid)
  end

  def save_file(tmp_file, filepath, message, user, iri=nil)
    version = nil

    git.add_file({email: user[:email], name: user[:name]}, tmp_file, filepath, message) do |commit_oid|
      version = save_ontology(commit_oid, filepath, user, iri)
    end
    touch
    version
  end

  def save_ontology(commit_oid, filepath, user, iri=nil)
    o = ontologies.where(path: filepath).first

    if o
      # update existing ontology
      version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
      o.ontology_version = version
      o.save!
    else
      # create new ontology
      clazz  = %w{.dol .casl}.include?(File.extname(filepath)) ? DistributedOntology : SingleOntology
      o      = clazz.new
      o.path = filepath

      o.iri  = iri || "http://#{Settings.hostname}/#{path}/#{Ontology.filename_without_extension(filepath)}"
      o.name = filepath.split('/')[-1].split(".")[0].capitalize

      version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })

      o.repository = self
      o.save!
      o.ontology_version = version;
      o.save!
    end

    version
  end

  def path_exists?(path, commit_oid=nil)
    path ||= '/'
    git.path_exists?(path, commit_oid)
  end

  def path_info(path=nil, commit_oid=nil)
    path ||= '/'

    if path_exists?(path, commit_oid)
      file = git.get_file(path, commit_oid)
      if file
        {
          type: :file,
          file: file
        }
      else
        entries = list_folder(path, commit_oid)
        entries.each do |name, es|
          es.each do |e|
            o = ontologies.where(path: e[:path]).first
            e[:ontology] = o
          end
        end
        {
          type: :dir,
          entries: entries
        }
      end
    else
      file = path.split('/')[-1]
      path = path.split('/')[0..-2].join('/')

      entries = git.folder_contents(commit_oid, path).select { |e| e[:name].split('.')[0] == file }

      case
      when entries.empty?
        nil
      when entries.size == 1
        {
          type: :file_base,
          entry: entries[0],
        }
      else
        {
          type: :file_base_ambiguous,
          entries: entries
        }
      end
    end
  end

  def read_file(filepath, commit_oid=nil)
    git.get_file(filepath, commit_oid)
  end

  # given a commit oid or a branch name, commit_id returns a hash of oid and branch name if existent
  def commit_id(oid)
    return { oid: git.head_oid, branch_name: 'master' } if oid.nil?
    if oid.match /[0-9a-fA-F]{40}/
      branch_names = git.branches.select { |b| b[:oid] == oid }
      if branch_names.empty?
        { oid: oid, branch_name: nil }
      else
        { oid: oid, branch_name: branch_names[0][:name] }
      end
    else
      if git.branch_oid(oid).nil?
        nil
      else
        { oid: git.branch_oid(oid), branch_name: oid }
      end
    end
  end

  def entries_info(oid=nil, path=nil)
    dirpath = git.get_path_of_dir(oid, path)
    git.entries_info(oid,dirpath)
  end

  def changed_files(oid=nil)
    git.changed_files(commit_id(oid)[:oid])
  end

  def commits(oid=nil, path=nil)
    git.commits(commit_id(oid)[:oid], path)
  end

  def sync
    unless source_type.nil?
      repo_working_copy = GitRepository.new(local_path_working_copy)

      result_pull = case source_type
      when Repository::SourceTypes::GIT
        repo_working_copy.pull
      when Repository::SourceTypes::SVN
        repo_working_copy.svn_rebase
      else
        raise Repository::ImportError, "unknown source type: #{source_type}"
      end
      result_push = repo_working_copy.push

      {
        success: result_pull[:success] && result_push[:success],
        head_oid_pre: result_pull[:head_oid_pre],
        head_oid_post: result_pull[:head_oid_post]
      }
    end
  end

  module ClassMethods
    # creates a new repository and imports the contents from the source git repository
    def import_from_git(user, source, name, params={})
      raise Repository::ImportError, "#{source} is not a git repository" unless GitRepository.is_git_repository? source

      params[:name] = name
      params[:source_type] = Repository::SourceTypes::GIT
      params[:source_address] = source

      r = Repository.create!(params)
      r.user = user
      r.save!
      r.destroy_git

      result_wc = GitRepository.clone_git(source, r.local_path_working_copy, false)
      result_bare = GitRepository.clone_git(r.local_path_working_copy, r.local_path, true)

      r.git!

      result_remote_rm  = r.git.remote_rm_origin
      result_remote_set = GitRepository.new(r.local_path_working_copy).remote_set_url_push(r.local_path)

      unless result_wc[:success] && result_bare[:success] && result_remote_rm[:success] && result_remote_set[:success]
        r.destroy
        raise Repository::ImportError, 'could not import repository'
      end

      r
    end

    # creates a new repository and imports the contents from the source svn repository
    def import_from_svn(user, source, name, params={})
      raise Repository::ImportError, "#{source} is not an svn repository" unless GitRepository.is_svn_repository? source

      params[:name] = name
      params[:source_type] = Repository::SourceTypes::SVN
      params[:source_address] = source

      r = Repository.create!(params)
      r.user = user
      r.save!
      r.destroy_git

      result_clone = GitRepository.clone_svn(source, r.local_path, r.local_path_working_copy)
      unless result_clone[:success]
        r.destroy
        raise Repository::ImportError, 'could not import repository'
      end

      r.git!

      r
    end
  end
end
