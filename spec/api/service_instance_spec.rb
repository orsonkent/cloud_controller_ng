# Copyright (c) 2009-2011 VMware, Inc.

require File.expand_path("../spec_helper", __FILE__)

describe VCAP::CloudController::ServiceInstance do

  it_behaves_like "a CloudController API", {
    :path                 => "/v2/service_instances",
    :model                => VCAP::CloudController::Models::ServiceInstance,
    :basic_attributes     => [:name, :credentials, :vendor_data],
    :required_attributes  => [:name, :credentials, :app_space_guid, :service_plan_guid],
    :unique_attributes    => [:app_space_guid, :name],
    :one_to_many_collection_ids => {
      :service_bindings => lambda { |service_instance|
        make_service_binding_for_service_instance(service_instance)
      }
    }
  }

  describe "quota" do
    let(:cf_admin) { Models::User.make(:admin => true) }
    let(:service_instance) { Models::ServiceInstance.make }

    describe "create" do
      it "should fetch a quota token" do
        should_receive_quota_call
        post "/v2/service_instances", Yajl::Encoder.encode(:name => Sham.name,
                                                           :app_space_guid => service_instance.app_space_guid,
                                                           :credentials => {},
                                                           :service_plan_guid => service_instance.service_plan_guid),
                                                           headers_for(cf_admin)
        last_response.status.should == 201
      end
    end

    describe "get" do
      it "should not fetch a quota token" do
        should_not_receive_quota_call
        get "/v2/service_instances/#{service_instance.guid}", {}, headers_for(cf_admin)
        last_response.status.should == 200
      end
    end

    describe "update" do
      it "should fetch a quota token" do
        should_receive_quota_call
        put "/v2/service_instances/#{service_instance.guid}",
            Yajl::Encoder.encode(:name => "#{service_instance.name}_renamed"),
            headers_for(cf_admin)
        last_response.status.should == 201
      end
    end

    describe "delete" do
      it "should not fetch a quota token" do
        should_receive_quota_call
        delete "/v2/service_instances/#{service_instance.guid}", {}, headers_for(cf_admin)
        last_response.status.should == 204
      end
    end
  end

end
