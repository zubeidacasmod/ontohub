require 'test_helper'

# Tests a git repository
#
# Author: Eugen Kuksa <eugenk@informatik.uni-bremen.de>

class GitRepositoryTest < ActiveSupport::TestCase

  context 'creating and deleting a repository' do
    setup do
      @path = '/tmp/ontohub/test/unit/git/repository'
    end

    teardown do
      FileUtils.rmtree(@path) if File.exists?(@path)
      @path = nil
      @repository = nil
    end

    should 'create repository' do
      @path_new = "#{@path}_new"
      assert !File.exists?(@path_new)
      @repository_new = GitRepository.new(@path_new)
      assert File.exists?(@path_new)
      assert @repository_new.empty?
    end

    should 'delete repository' do
      @path_new = "#{@path}_new"
      @repository_new = GitRepository.new(@path_new)
      assert File.exists?(@path_new)
      @repository_new.destroy
      assert !File.exists?(@path_new)
    end
  end

  context 'existing repository' do
    setup do
      @path = '/tmp/ontohub/test/unit/git/repository'
      @repository = GitRepository.new(@path)
      @userinfo = {
        email: 'jan@jansson.com',
        name: 'Jan Jansson',
        time: Time.now
      }
    end

    teardown do
      FileUtils.rmtree(@path) if File.exists?(@path)
      @path = nil
      @repository = nil
    end

    context 'using files' do
      setup do
        @filepath = 'path/file.txt'
        @content = 'Some content'
        @message = 'Some commit message'
      end

      should 'create single commit of a file' do
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        assert @repository.path_exists?(@filepath)
        assert_equal @repository.get_file(@filepath)[:name], @filepath.split('/')[-1]
        assert_equal @repository.get_file(@filepath)[:content], @content
        assert_equal @repository.get_file('path/file.txt')[:mime_type], Mime::Type.lookup('text/plain')
        assert_equal @repository.commit_message, @message
        assert_equal @repository.commit_author[:name], @userinfo[:name]
        assert_equal @repository.commit_author[:email], @userinfo[:email]
        # removed because of time zone issues
        #assert_equal Time.at(@repository.commit_author[:time]), Time.gm(@userinfo[:time])
      end

      should 'delete a file' do
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        @repository.delete_file(@userinfo, @filepath)
        assert !@repository.path_exists?(@filepath)
      end

      should 'overwrite a file' do
        content2 = "#{@content}_2"
        message2 = "#{@message}_2"
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        first_commit_oid = @repository.head_oid
        @repository.commit_file(@userinfo, content2, @filepath, message2)
        assert @repository.path_exists?(@filepath)
        assert_equal @repository.get_file(@filepath)[:content], content2
        assert_equal @repository.commit_message(@repository.head_oid), message2
        assert_not_equal first_commit_oid, @repository.head_oid
      end

      should 'reset state on empty repository with failing commit block' do
        assert @repository.empty?
        assert_raise Exception do
          @repository.commit_file(@userinfo, @content, @filepath, @message) do
            raise Exception
          end
        end
        # it is actually empty, but in this test this can't be found out
        #assert @repository.empty?
      end

      should 'reset state with failing commit block' do
        first_commit_oid = @repository.commit_file(@userinfo, @content, @filepath, @message)
        assert_equal first_commit_oid, @repository.head_oid
        assert_raise Exception do
          second_commit_oid = @repository.commit_file(@userinfo, "#{@content}!", @filepath, @message) do
            raise Exception
          end
        end
        # it is actually equal, but in this test this can't be found out
        #assert_equal first_commit_oid, @repository.head_oid
      end
    end

    context 'using folders' do
      setup do
        @subfolder = 'path'
        @filepath1 = "#{@subfolder}/file1.txt"
        @filepath2 = "#{@subfolder}/file2.txt"
        @filepath3 = 'file3.txt'
        @content = 'Some content'
        @message1 = 'Some commit message1'
        @message2 = 'Some commit message2'
        @message3 = 'Some commit message3'
        @commit_add1 = @repository.commit_file(@userinfo, @content, @filepath1, @message1)
        @commit_add2 = @repository.commit_file(@userinfo, @content, @filepath2, @message2)
        @commit_add3 = @repository.commit_file(@userinfo, @content, @filepath3, @message3)
        @commit_del1 = @repository.delete_file(@userinfo, @filepath1)
        @commit_del2 = @repository.delete_file(@userinfo, @filepath2)
        @commit_del3 = @repository.delete_file(@userinfo, @filepath3)
      end

      should 'read the right number of contents in the root folder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1).size, 1
      end

      should 'read the right contents in the root folder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1), [{
            type: :dir,
            name: @subfolder,
            path: @subfolder
          }]
      end

      should 'read the right number of contents in the subfolder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1, @subfolder).size, 1
      end

      should 'read the right contents in the subfolder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        }]
      end


      should 'read the right number of contents in the root folder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2).size, 1
      end

      should 'read the right contents in the root folder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        }]
      end

      should 'read the right number of contents in the subfolder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2, @subfolder).size, 2
      end

      should 'read the right contents in the subfolder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        },{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end


      should 'read the right number of contents in the root folder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3).size, 2
      end

      should 'read the right contents in the root folder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        },{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end

      should 'read the right number of contents in the subfolder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3, @subfolder).size, 2
      end

      should 'read the right contents in the subfolder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        },{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end

      should 'treat path "/" and empty path equally' do
        assert_equal @repository.folder_contents(@commit_add3, '/'), @repository.folder_contents(@commit_add3)
        assert_equal @repository.folder_contents(@commit_add3, '/'), @repository.folder_contents(@commit_add3, nil)
      end


      should 'read the right number of contents in the root folder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1).size, 2
      end

      should 'read the right contents in the root folder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        },{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end

      should 'read the right number of contents in the subfolder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1, @subfolder).size, 1
      end

      should 'read the right contents in the subfolder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1, @subfolder), [{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end


      should 'read the right number of contents in the root folder after deleting the second file' do
        assert_equal @repository.folder_contents(@commit_del2).size, 1
      end

      should 'read the right contents in the root folder after deleting the second file' do
        assert_equal @repository.folder_contents(@commit_del2), [{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end


      should 'read the right number of contents in the root folder after deleting the third file' do
        assert_equal @repository.folder_contents(@commit_del3).size, 0
      end

      should 'read the right contents in the root folder after deleting the third file' do
        assert_equal @repository.folder_contents(@commit_del3), []
      end
    end

    context 'getting the commit history' do
      setup do
        @filepath = 'path/to/file.txt'
        @commit_add1 = @repository.commit_file(@userinfo, 'Some content1', @filepath, 'Add')
        @commit_change1 = @repository.commit_file(@userinfo, 'Some other content1', @filepath, 'Change')
        @commit_other1 = @repository.commit_file(@userinfo, 'Other content1', 'file2.txt', 'Other File: Add')
        @commit_delete1 = @repository.delete_file(@userinfo, @filepath)
        @commit_other2 = @repository.commit_file(@userinfo, 'Other content2', 'file2.txt', 'Other File: Change1')
        @commit_other3 = @repository.commit_file(@userinfo, 'Other content3', 'file2.txt', 'Other File: Change2')
        @commit_add2 = @repository.commit_file(@userinfo, 'Some content2', @filepath, 'Re-Add')
        @commit_change2 = @repository.commit_file(@userinfo, 'Some other content2', @filepath, 'Re-Change')
        @commit_delete2 = @repository.delete_file(@userinfo, @filepath)
      end

      should 'list all commits regarding the whole branch' do
        assert_equal @repository.commits(@commit_delete2), @repository.commits
        assert_equal [ @commit_delete2, @commit_change2, @commit_add2,
                       @commit_other3, @commit_other2, @commit_delete1,
                       @commit_other1, @commit_change1, @commit_add1 ],
                     @repository.commits.map{ |c| c[:oid] }
        assert_equal 2, @repository.commits(@commit_change1).size
      end

      should 'have the correct values in the history at the HEAD' do
        assert_equal @repository.commits(@commit_delete2, @filepath), @repository.commits(nil, @filepath)
        assert_equal [
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(nil, @filepath).map{ |c| c[:oid] }
      end

      should 'have the correct values in the history a commit before the HEAD' do
        assert_equal [
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(@commit_change2, @filepath).map{ |c| c[:oid] }
      end

      should 'have the correct values in the history in the commit that changes another file' do
        assert_equal [
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(@commit_other3, @filepath).map{ |c| c[:oid] }
      end
    end


    context 'getting the list of changed files' do
      setup do
        @content1 = "Some\ncontent\nwith\nmany\nlines."
        @content2 = "Some\ncontent,\nwith\nmany\nlines."
        @filepath = 'path/to/file.xml'
        @file_extension = @filepath.split('.')[-1]
        @commit1 = @repository.commit_file(@userinfo, @content1, @filepath, 'Message1')
        @commit2 = @repository.commit_file(@userinfo, @content2, @filepath, 'Message2')
        @commit3 = @repository.delete_file(@userinfo, @filepath)
      end

      should 'last commit be HEAD' do
        assert_equal @repository.is_head?(@commit3), true
      end


      should 'have the right file count when using the first commit' do
        assert_equal @repository.changed_files(@commit1).size, 1
      end

      should 'have the right name in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:name], 'file.xml'
      end

      should 'have the right path in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:path], @filepath
      end

      should 'have the right type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:type], :add
      end

      should 'have the right mime type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:editable], true
      end



      should 'have the right file count when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).size, 1
      end

      should 'have the right name in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:name], @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:path], @filepath
      end

      should 'have the right type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:type], :change
      end

      should 'have the right mime type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:editable], true
      end



      should 'have the right file count when using the HEAD' do
        assert_equal @repository.changed_files.size, 1
      end

      should 'have the right name in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:name], @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:path], @filepath
      end

      should 'have the right type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:type], :delete
      end

      should 'have the right mime type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:editable], true
      end
    end

    context 'being cloned' do
      setup do
        @commit_count = 10
        @commit_count.times do |n|
          @content = "content #{n}"
          @filepath = "file-#{n}"
          @message = "message #{n}"
          @repository.commit_file(@userinfo, @content, @filepath, @message)
        end

        @path_clone = '/tmp/ontohub/test/unit/git/repository_clone'
        assert !File.exists?(@path_clone), 'Folder to clone into already exists'
      end

      teardown do
        FileUtils.rmtree(@path_clone) if File.exists?(@path_clone)
        @path_clone = nil
      end

      context 'fully from filesystem into a bare repository' do
        setup do
          @result = GitRepository.clone_git("file://#{@path}", @path_clone, true)
          @repository_clone = GitRepository.new(@path_clone)
        end

        teardown do
          @repository_clone = nil
        end

        should 'be sueccessful' do
          assert @result[:success]
        end

        should 'be a bare repository' do
          assert GitRepository.is_bare_repository?(@path_clone)
        end

        should 'not be an svn clone' do
          assert !@repository_clone.is_svn_clone?
        end

        should 'clone all commits' do
          assert_equal @repository.commits, @repository_clone.commits
        end

        should 'create the same branches in the clone' do
          assert(@repository.branches & @repository_clone.branches == @repository.branches, 'The original branches are not a subset of the clone branches.')
        end
      end

      context 'fully from filesystem into repository with working copy' do
        setup do
          @result = GitRepository.clone_git("file://#{@path}", @path_clone)
          @repository_clone = GitRepository.new(@path_clone)
        end

        teardown do
          @repository_clone = nil
        end

        should 'be sueccessful' do
          assert @result[:success]
        end

        should 'be a repository with working copy' do
          assert GitRepository.is_repository_with_working_copy?(@path_clone)
        end

        should 'not be an svn clone' do
          assert !@repository_clone.is_svn_clone?
        end

        should 'clone all commits' do
          assert_equal @repository.commits, @repository_clone.commits
        end

        should 'create the same branches in the clone' do
          assert(@repository.branches & @repository_clone.branches == @repository.branches, 'The original branches are not a subset of the clone branches.')
        end

        should 'be able to pull new changes' do
          head_oid_pre = @repository.head_oid
          @repository.commit_file(@userinfo, @content+'new', @filepath, 'change file for pull')
          head_oid_post = @repository.head_oid
          result = @repository_clone.pull
          
          assert result[:success], "Pull was unseccessful: #{result[:err]}"
          assert_equal head_oid_pre, result[:head_oid_pre]
          assert_equal head_oid_post, result[:head_oid_post]
          assert_equal @repository.commits, @repository_clone.commits
        end
      end
    end
  end

  context 'importing an svn repository (takes a lot of time)' do
    setup do
      @path_clone_wc = '/tmp/ontohub/test/unit/git/repository_clone_wc'
      @path_clone_bare = '/tmp/ontohub/test/unit/git/repository_clone_bare'
      @result = GitRepository.clone_svn('http://colore.googlecode.com/svn/trunk/ontologies/owltime', @path_clone_bare, @path_clone_wc)
      @repository_clone_wc = GitRepository.new(@path_clone_wc)
      @repository_clone_bare = GitRepository.new(@path_clone_bare)

      DIR = File.dirname(__FILE__)
      SCRIPT_REMOTE_V = "#{DIR}/git_repository_remote_v.sh"
    end

    teardown do
      FileUtils.rmtree(@path_clone_wc) if File.exists?(@path_clone_wc)
      FileUtils.rmtree(@path_clone_bare) if File.exists?(@path_clone_bare)
      @result = nil
      @repository_clone_wc = nil
      @repository_clone_bare = nil
    end

    # merged all tests into a single test sincy cloning takes very long time
    # there are no functions tested that cause side effects
    should 'work properly' do
      assert @result[:success], "Cloning was unsuccessful: #{@result[:err]}"
      assert @repository_clone_wc.is_svn_clone?, "Working copy is not an svn clone"
      assert !@repository_clone_bare.is_svn_clone?, "Bare repo is an svn clone"
      assert GitRepository.is_repository_with_working_copy?(@path_clone_wc), 'Clone is not a valid repository with working copy'
      assert GitRepository.is_bare_repository?(@path_clone_bare), 'Clone is not a valid bare repository'

      # remote handling for working copy
      stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_REMOTE_V, @path_clone_wc
      assert wait_thr.value.success?
      out = stdout.gets(nil).gsub(/origin\s+(.*)\(.*\)\s/, '\1').split.uniq
      assert_equal [@path_clone_bare], out, 'working copy does not have any remotes'

      # remote handling for bare repo
      stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_REMOTE_V, @path_clone_bare
      assert wait_thr.value.success?
      assert_nil stdout.gets(nil), 'bare repository has remotes'

      assert_equal @repository_clone_wc.commits, @repository_clone_bare.commits
    end
  end

  context 'importing new changes from svn and pushing them into the bare repo' do
    setup do
      @path_clone_wc = '/tmp/ontohub/test/unit/git/repository_clone_wc'
      @path_clone_bare = '/tmp/ontohub/test/unit/git/repository_clone_bare'
      @result = GitRepository.clone_svn('http://colore.googlecode.com/svn/trunk/ontologies/owltime', @path_clone_bare, @path_clone_wc, 703)
      @repository_clone_wc = GitRepository.new(@path_clone_wc)
      @repository_clone_bare = GitRepository.new(@path_clone_bare)
    end

    teardown do
      FileUtils.rmtree(@path_clone_wc) if File.exists?(@path_clone_wc)
      FileUtils.rmtree(@path_clone_bare) if File.exists?(@path_clone_bare)
      @result = nil
      @repository_clone_wc = nil
      @repository_clone_bare = nil
    end


    # merged all tests into a single test sincy cloning takes very long time
    # there are no functions tested that cause side effects
    should 'work properly' do
      head_oid_pre = @repository_clone_wc.head_oid
      result_rebase = @repository_clone_wc.svn_rebase
      head_oid_post = @repository_clone_wc.head_oid
      assert result_rebase[:success], "rebase failed:\n#{result_rebase[:out]}\n#{result_rebase[:err]}"
      assert(@repository_clone_wc.commits.size > @repository_clone_bare.commits.size, 'no new commits in working copy')

      result_push = @repository_clone_wc.push
      assert result_push[:success], "push failed:\n#{result_push[:out]}\n#{result_push[:err]}"
      assert_equal @repository_clone_wc.commits, @repository_clone_bare.commits

      assert_equal head_oid_pre, result_rebase[:head_oid_pre]
      assert_equal head_oid_post, result_rebase[:head_oid_post]
    end
  end
end