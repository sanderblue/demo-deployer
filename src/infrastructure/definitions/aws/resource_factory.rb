require  "./src/infrastructure/definitions/aws/ec2_resource"
require  "./src/infrastructure/definitions/aws/elb_resource"
require  "./src/infrastructure/definitions/aws/lambda_resource"
require  "./src/infrastructure/definitions/aws/r53ip_resource"

module Infrastructure
  module Definitions
    module Aws
      class ResourceFactory

        def initialize(user_config_provider, tag_provider, default_user_name = "ec2-user")
          @user_config_provider = user_config_provider
          @tag_provider = tag_provider
          @default_user_name = default_user_name
        end

        def create(config_resource)
          resource_id = config_resource["id"]
          tags = @tag_provider.get_resource_tags(resource_id)
          user_name = (config_resource["user_name"] || @default_user_name)
          credential = get_credential()

          case config_resource["type"]
            when "ec2"
              return Ec2Resource.new(resource_id, credential, config_resource["size"], user_name, tags)

            when "elb"
              return ElbResource.new(resource_id, credential, config_resource["listeners"], user_name, tags)

            when "lambda"
              return LambdaResource.new(resource_id, credential, user_name, tags)

            when "r53ip"
              domain = config_resource["domain"]
              listeners = config_resource["listeners"]
              reference_id = config_resource["reference_id"]
              return R53IpResource.new(resource_id, credential, domain, listeners, reference_id)
          end

          return nil
        end

        private
        def get_credential()
          return @user_config_provider.get_aws_credential()
        end

      end
    end
  end
end