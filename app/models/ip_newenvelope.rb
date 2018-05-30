class IpNewenvelope < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'
  require 'openssl'
  require 'base64'
  # require 'dotenv'
  # Dotenv.load('../.env')

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      IpNewenvelope.create(ip_email: row[1], nric: row[2], ip_name: row[3], driver_phone_no: row[4],
                           licence_plate: row[5], min_rental_period: row[6], name_of_bank: row[7],
                           bank_account_no: row[8], emergency_name: row[9], emergency_phone_no: row[10],
                           vehicle_make: row[11], vehicle_model: row[12], pickup_date: row[13], user: user)
    end
  end

  def self.docu_auth
    host = 'https://demo.docusign.net/restapi'
    integrator_key = '8df67330-80dc-43c7-ab37-8d02bd7ef07f'
    user_id = 'b2a3170b-dab0-4d0d-ba2e-c7580ae92125'
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account-d.docusign.com'
    # private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'
    @private_key_filename = ENV["PRIVATE_KEY_DEMO"]
    puts ENV["PRIVATE_KEY_DEMO"]
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

  def self.convert_date(date_str)
    day_str = date_str.split('-')[2]
    month_str = date_str.split('-')[1]
    year_str = date_str.split('-')[0][2,2]
    final_date = day_str+'/'+month_str+'/'+year_str
    return final_date
  end

  def self.allocate_tabs(array_ml,tab_label_str)
    if tab_label_str == "IP_Email"
        return array_ml.ip_email
    elsif tab_label_str == "NRIC"
        return array_ml.nric
    elsif tab_label_str == "IP_Name"
        return array_ml.ip_name
    elsif tab_label_str == "Driver_Phone_No"
        return array_ml.driver_phone_no
    elsif tab_label_str == "Licence_Plate"
        return array_ml.licence_plate
    elsif tab_label_str == "Min_Rental_Period"
        return array_ml.min_rental_period
    elsif tab_label_str == "Name_of_Bank"
        return array_ml.name_of_bank
    elsif tab_label_str == "Bank_Account_No"
        return array_ml.bank_account_no
    elsif tab_label_str == "Emergency_Name"
        return array_ml.emergency_name
    elsif tab_label_str == "Emergency_Phone_No"
        return array_ml.emergency_phone_no
    elsif tab_label_str == "Vehicle_Make"
        return array_ml.vehicle_make
    elsif tab_label_str == "Vehicle_Model"
        return array_ml.vehicle_model
    elsif tab_label_str == "Pickup_Date"
        return self.convert_date(array_ml.pickup_date.to_s)
    elsif tab_label_str == "Payee_Name"
        return array_ml.ip_name
    end
  end

  def self.send_env(selected_envelopes)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    ed = DocuSign_eSign::EnvelopeDefinition.new
    ed.template_id = '28d4b9b6-4627-455a-bfd6-dfed3b08c97c'
    ee = DocuSign_eSign::Envelope.new
    selected_envelopes.each do |i|
      create_env = ea.create_envelope(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4', envelope_definition=ed)
      e_id = create_env.envelope_id
      options = DocuSign_eSign::ListTabsOptions.new
      options.include_metadata = "True"
      env_tabs = ea.list_tabs(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4',envelope_id=e_id,recipient_id="1",options)
      contain_one = []
      contain = []
      env_tabs.email_tabs.each do |k|
        empty_dict_1 = {}
        empty_dict_1["value"] = self.allocate_tabs(i,k.tab_label)
        empty_dict_1[:documentId] = "1"
        empty_dict_1[:tabId] = k.tab_id
        contain_one = contain_one + [empty_dict_1]
      end
      env_tabs.text_tabs.each do |j|
        empty_dict = {}
        empty_dict[:value] = self.allocate_tabs(i,j.tab_label)
        empty_dict[:documentId] = "1"
        empty_dict[:tabId] = j.tab_id
        contain = contain + [empty_dict]
      end
      text_tabs_list = {"textTabs":contain,"emailTabs":contain_one}
      ee.email_subject = 'LCR Contract YL Demo Webapp 2 ' + i.nric.to_s
      # ee.email_blurb = open('FRD_Eligible.txt','r').read()
      ee.status = 'sent'
      # ee.brand_id = "a7acf8d2-d402-40a9-b096-52d7962cccd5" # Brand_LCR
      signer_placeholder ={"inPersonSigners":[{"hostEmail":"contracts@lioncityrentals.com.sg",
                                               "hostName":"LCR Contracts","signerName":i.ip_name.to_s,
                                               "signerEmail":i.ip_email.to_s,
                                               "routingOrder":1,"recipientId":"1",
                                               "tabs":text_tabs_list}]}
      ee.recipients = signer_placeholder
      options3 = DocuSign_eSign::UpdateOptions.new
      options3.advanced_update = "True"

      ea.update(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4',envelope_id=e_id,envelope=ee,options3)
    end
  end
end