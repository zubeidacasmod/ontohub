require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  should route(:get, "/users/id").to(:controller=> :users, :action => :show, :id => 'id')
  
  context 'User Instance' do
    setup do
      @user = Factory :user
    end
    
    context 'without data' do
      context 'on GET to show' do
        setup do
          get :show, :id => @user.to_param
        end
        
        should assign_to :versions
        should assign_to :comments
        should respond_with :success
        should render_template :show
      end
    end
    
    context 'with data' do
      setup do
        OntologyVersion.any_instance.expects(:parse_async).once
        
        Factory :comment, :user => @user
        Factory :ontology_version, :user => @user
      end
      context 'on GET to show' do
        setup do
          get :show, :id => @user.to_param
        end
        
        should assign_to :versions
        should assign_to :comments
        should respond_with :success
        should render_template :show
      end
    end
  end
  
end