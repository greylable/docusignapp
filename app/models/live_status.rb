class LiveStatus < ApplicationRecord
  belongs_to :user, required: false
  require 'base64'

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

  def self.get_doc(envelope_rental)
    # self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    file_contents = ea.get_document(account_id=ENV["ACCOUNT_ID_LIVE"], recipient_id="1", envelope_id=envelope_rental[0])
    fileName = 'Rental_' + envelope_rental[1].to_s + '_Envelope_' + envelope_rental[0].to_s
    base64_doc = Base64.encode64(File.open(file_contents, "rb").read).encode('iso-8859-1').force_encoding('utf-8')
    decoded_doc = Base64.decode64(base64_doc)
    return [fileName,decoded_doc]
  end

  def self.fetch_info(envelope_id)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    envelope_data = ea.get_form_data(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=envelope_id)
    form_data = envelope_data.form_data

    recipient_details = ea.list_recipients(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=envelope_id)
    if recipient_details.signers.present?
      empty_dict = {}

      form_data.each do |j|
        empty_dict[j.name] = j.value
      end

      header_list = ["Email","Rental","Name","NRIC","Mailing_Address","Driver_Phone_No","Birthday","Pickup_Date",
                     "Vehicle_Make","Vehicle_Model","Vehicle_Colour","Licence_Plate","Master_Rate","Weekly_Rate",
                     "Min_Rental_Period","Deposit"]
      contain_value = []
      header_list.each do |h|
        begin
          col_1 = empty_dict[h]
        rescue
          col_1 = ''
        end
        contain_value = contain_value + [col_1]
      end
      recipient_type = 'Signer'
      row = [envelope_id] + contain_value
      signer_details = recipient_details.signers[0]
      status = signer_details.status
      access_code = signer_details.access_code
      note = signer_details.note
      row = [status] + [recipient_type] + row + [access_code] + [note]
      return row

    elsif recipient_details.in_person_signers.present?
      empty_dict = {}

      form_data.each do |j|
        empty_dict[j.name] = j.value
      end

      header_list = ["IP_Email","Rental","IP_Name","NRIC","Mailing_Address","Driver_Phone_No","Birthday","Pickup_Date",
                     "Vehicle_Make","Vehicle_Model","Vehicle_Colour","Licence_Plate","Master_Rate","Weekly_Rate",
                     "Min_Rental_Period","Deposit"]
      contain_value = []
      header_list.each do |h|
        begin
          col_1 = empty_dict[h]
        rescue
          col_1 = ''
        end
        contain_value = contain_value + [col_1]
      end
      recipient_type = 'In Person'
      row = [envelope_id] + contain_value
      signer_details = recipient_details.in_person_signers[0]
      status = signer_details.status
      access_code = signer_details.access_code
      note = signer_details.note
      row = [status] + [recipient_type] + row + [access_code] + [note]
      return row
    end
  end
end
