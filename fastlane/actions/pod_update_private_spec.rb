module Fastlane
  module Actions
    module SharedValues
      POD_UPDATE_PRIVATE_SPEC_CUSTOM_VALUE = :POD_UPDATE_PRIVATE_SPEC_CUSTOM_VALUE
    end

    class PodUpdatePrivateSpecAction < Action
      def self.run(params)
        # params[:参数名称] 参数名称与下面self.available_options中的保持一致
        privatesSpecName=params[:repo]
         command = []
         command << "pod repo update #{privatesSpecName}"
        # sh "shellcommand ./path"
        
        # Actions.lane_context[SharedValues::POD_UPDATE_PRIVATE_SPEC_CUSTOM_VALUE] = "my_val"
         result = Actions.sh(command.join('&'))
         UI.success("Successfully update private spec 🚀 ")
         return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "升级本地私有所有库"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "更新本地私有索引库,pod repo update 私有索引库"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
            FastlaneCore::ConfigItem.new(key: :repo,
                                         description: "私有索引库的名称",
                                         is_string: true,
                                         default_value: "RCSpecs")# 默认值是是本地私有索引库
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['POD_UPDATE_PRIVATE_SPEC_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["gongjiahao"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
