unless Fog.mocking?

  module Fog
    module AWS
      class EC2

        # Acquire an elastic IP address.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'publicIp'<~String> - The acquired address
        #     * 'requestId'<~String> - Id of the request
        def allocate_address
          request({
            'Action' => 'AllocateAddress'
          }, Fog::Parsers::AWS::EC2::AllocateAddress.new)
        end

      end
    end
  end

else

  module Fog
    module AWS
      class EC2

        def allocate_address
          response = Excon::Response.new
          response.status = 200
          public_ip = Fog::AWS::Mock.ip_address
          data ={
            'instanceId' => '',
            'publicIp'   => public_ip
          }
          Fog::AWS::EC2.data[:addresses][public_ip] = data
          response.body = {
            'publicIp'  => public_ip,
            'requestId' => Fog::AWS::Mock.request_id
          }
          response
        end

      end
    end
  end

end
