class Resendenv < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      Resendenv.create(envelope_id: row[0], user: user)
    end
  end

  def self.docu_auth
    host = 'https://eu.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_LIVE"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account.docusign.com'
    # private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'
    @private_key_filename = ENV["PRIVATE_KEY_LIVE"]
    puts ENV["PRIVATE_KEY_LIVE"]
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

    def self.fetch_info(selected_envelopes, user)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    selected_envelopes.each do |i|
      envelope_data = ea.get_form_data(account_id='bb376ad2-0e72-4e2f-8226-615ea4fecfcf',envelope_id=i.envelope_id)
      form_data = envelope_data.form_data
      # e_id = envelope_data.envelope_id
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
      row = [i.envelope_id] + contain_value


      signer_details = ea.list_recipients(account_id='bb376ad2-0e72-4e2f-8226-615ea4fecfcf',envelope_id=i.envelope_id).signers[0]
      access_code = signer_details.access_code
      note = signer_details.note
      row = row + [access_code] + [note]

      Resendenv.where('envelope_id LIKE ?', i.envelope_id).update(envelope_id: row[0], email: row[1], rental: row[2], name: row[3], nric: row[4],
                                                                               mailing_address: row[5], driver_phone_no: row[6], birthday: row[7], pickup_date: row[8],
                                                                               vehicle_make: row[9], vehicle_model: row[10], vehicle_colour: row[11], licence_plate: row[12],
                                                                               master_rate: row[13], weekly_rate: row[14], min_rental_period: row[15], deposit: row[16],
                                                                               accesscode: row[17], note: row[18], user: user)

    end

  end

end
