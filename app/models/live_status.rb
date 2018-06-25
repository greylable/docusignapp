class LiveStatus < ApplicationRecord
  belongs_to :user, required: false

  def self.docu_auth
    host = 'https://eu.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_LIVE"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account.docusign.com'
    # private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'
    @private_key_filename = ENV["PRIVATE_KEY_LIVE"]
    # puts ENV["PRIVATE_KEY_LIVE"]
    # private_key_filename = ENV["PRIVATE_KEY_DEMO"].to_s.gsub("\\n", "\n")

    # STEP 1: Initialize API Client
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = host

    @api_client = DocuSign_eSign::ApiClient.new(configuration)
    @api_client.configure_jwt_authorization_flow(@private_key_filename, auth_server, integrator_key, user_id, expires_in_seconds)

    # STEP 2: Initialize Authentication API using the API Client
    authentication_api = DocuSign_eSign::AuthenticationApi.new(@api_client)


    # STEP 3: Make the login call
    login_options = DocuSign_eSign::LoginOptions.new
    login_information = authentication_api.login(login_options)

    if !login_information.nil?
      login_information.login_accounts.each do |login_account|
        if login_account.is_default == "true"
          # STEP 4: Extract the user information
          base_url = login_account.base_url
          account_id = login_account.account_id

          puts base_url
          puts account_id
          puts "authenticated successfully"

          # IMPORTANT: Use the base url from the login account to update the api client which will be used in future api calls
          base_uri = URI.parse(base_url)
          @api_client.config.host = "%s://%s/restapi" % [base_uri.scheme, base_uri.host]
        end
      end
    end
  end

  def self.fetch_info(envelope_id)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    envelope_data = ea.get_form_data(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=envelope_id)
    form_data = envelope_data.form_data
    puts form_data

  #   empty_dict = {}
  #
  #   form_data.each do |j|
  #     empty_dict[j.name] = j.value
  #   end
  #
  #   header_list = ["Rental","NRIC","Mailing_Address","Driver_Phone_No","Birthday","Pickup_Date",
  #                  "Vehicle_Make","Vehicle_Model","Vehicle_Colour","Licence_Plate","Master_Rate","Weekly_Rate",
  #                  "Min_Rental_Period","Deposit"]
  #   contain_value = []
  #   header_list.each do |h|
  #     begin
  #       col_1 = empty_dict[h]
  #     rescue
  #       col_1 = ''
  #     end
  #     contain_value = contain_value + [col_1]
  #   end
  #   row = [i.envelope_id] + contain_value
  #
  #
    signer_details = ea.list_recipients(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=envelope_id)#.signers[0]
    puts signer_details
  #   access_code = signer_details.access_code
  #   note = signer_details.note
  #   name = signer_details.name
  #   email = signer_details.email
  #   row = [status] + row + [access_code] + [note] + [name] + [email]
  #   puts row
  #
  #
  end
end
