class Resendenv < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      Resendenv.create(envelope_id: row[0], user: user)
    end
  end

  def self.import_msg(selected_envelopes, file, user)
    contain = ''
    File.foreach(file.path).with_index do |line|
      contain = contain + line
    end
    selected_envelopes.each do |i|
      Resendenv.where('envelope_id LIKE ?', i.envelope_id).update(email_blurb: contain, user: user)
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

      header_list = ["Rental","NRIC","Mailing_Address","Driver_Phone_No","Birthday","Pickup_Date",
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
      name = signer_details.name
      email = signer_details.email
      row = row + [access_code] + [note] + [name] + [email]


      Resendenv.where('envelope_id LIKE ?', i.envelope_id).update(envelope_id: row[0], rental: row[1], nric: row[2],
                                                                  mailing_address: row[3], driver_phone_no: row[4],
                                                                  birthday: row[5], pickup_date: row[6], vehicle_make: row[7],
                                                                  vehicle_model: row[8], vehicle_colour: row[9],
                                                                  licence_plate: row[10], master_rate: row[11],
                                                                  weekly_rate: row[12], min_rental_period: row[13],
                                                                  deposit: row[14], accesscode: row[15], note: row[16],
                                                                  name: row[17], email: row[18], user: user)

    end
  end

  def self.allocate_tabs(array_ml,tab_label_str)
    if tab_label_str == "Rental"
      return array_ml.rental
    elsif tab_label_str == "NRIC"
      return array_ml.nric
    elsif tab_label_str == "Mailing_Address"
      return array_ml.mailing_address
    elsif tab_label_str == "Driver_Phone_No"
      return array_ml.driver_phone_no
    elsif tab_label_str == "Birthday"
      return array_ml.birthday
    elsif tab_label_str == "Pickup_Date"
      return array_ml.pickup_date
    elsif tab_label_str == "Vehicle_Make"
      return array_ml.vehicle_make
    elsif tab_label_str == "Vehicle_Model"
      return array_ml.vehicle_model
    elsif tab_label_str == "Vehicle_Colour"
      return array_ml.vehicle_colour
    elsif tab_label_str == "Licence_Plate"
      return array_ml.licence_plate
    elsif tab_label_str == "Master_Rate"
      return array_ml.master_rate
    elsif tab_label_str == "Weekly_Rate"
      return array_ml.weekly_rate
    elsif tab_label_str == "Min_Rental_Period"
      return array_ml.min_rental_period
    elsif tab_label_str == "Deposit"
      return array_ml.deposit
    end
  end

  def self.resend_env(selected_envelopes)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    # ed = DocuSign_eSign::EnvelopeDefinition.new
    # ed.template_id = '864a92e9-0094-4e29-b59f-bdaa035faa9d'
    ee = DocuSign_eSign::Envelope.new
    selected_envelopes.each do |i|
      # create_env = ea.create_envelope(account_id=ENV["ACCOUNT_ID_LIVE"], envelope_definition=ed)
      # e_id = create_env.envelope_id
      options = DocuSign_eSign::ListTabsOptions.new
      options.include_metadata = "True"
      env_tabs = ea.list_tabs(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=i.envelope_id,recipient_id="1",options)
      contain = []
      env_tabs.text_tabs.each do |j|
        empty_dict = {}
        empty_dict[:value] = self.allocate_tabs(i,j.tab_label)
        empty_dict[:documentId] = "1"
        empty_dict[:tabId] = j.tab_id
        contain = contain + [empty_dict]
      end
      text_tabs_list = {"textTabs":contain}
      ee.email_subject = 'LCR Contract ' + i.email
      ee.email_blurb = i.email_blurb
      ee.status = 'sent'
      ee.brand_id = "a7acf8d2-d402-40a9-b096-52d7962cccd5" # Brand_LCR
      signer_placeholder ={"Signers":[{"name":i.name,
                                               "email":i.email,
                                               "routingOrder":1,"recipientId":"1",
                                               "tabs":text_tabs_list,
                                               "accessCode":i.accesscode,
                                               "note":i.note}]}
      ee.recipients = signer_placeholder
      options3 = DocuSign_eSign::UpdateOptions.new
      options3.advanced_update = "True"
      options3.resend_envelope = "True"
      ea.update(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=i.envelope_id,envelope=ee,options3)
    end
  end

end
