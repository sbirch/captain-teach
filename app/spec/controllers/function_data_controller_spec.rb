require 'spec_helper'

describe FunctionDataController do
  before(:each) do
    @user = User.new()
    @user.save()
    @fd = FunctionData.new(:ref => "foo", :user => @user)
    @fd.save()
  end

  it "POST create, only required params" do
    post :create, :ref => "foo", :user_id => @user.id,
         :format => :json
    resp = JSON::parse(response.body)
    resp["type"].should(eq("success"))
    resp["id"].should(be_a(Integer))
  end

  it "GET show, returns a FunctionData" do
    get :show, :id => @fd.id

    resp = JSON::parse(response.body)

    resp.should(be_a(Hash))
    resp["ref"].should(eq("foo"))
    resp["user_id"].should(eq(@user.id))
  end

  it "PUT update, update check_block, reflects in db" do
    check = "Some checks!"
    put :update, :id => @fd.id, :check_block => check
    @fd.reload()
    @fd.check_block.should(eq(check))
  end

  it "GET lookup_or_create, with existing FD" do
    get :lookup_or_create, :ref => @fd.ref, :user_id => @fd.user_id
    resp = JSON::parse(response.body)
    resp["id"].should(eq(@fd.id))
  end

  it "GET lookup_or_create, without existing FD" do
    get :lookup_or_create, :ref => "blah bar", :user_id => @fd.user_id
    resp = JSON::parse(response.body)
    resp["id"].should(be_a(Integer))
    resp["id"].should_not(eq(@fd.id))
  end
  
end
