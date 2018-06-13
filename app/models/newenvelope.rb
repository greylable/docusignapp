class Newenvelope < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true, encoding: 'iso-8859-1:utf-8') do |row|
      Newenvelope.create(email: row[0],rental: row[1], name: row[2], nric: row[3], mailing_address: row[4],
                        driver_phone_no: row[5], birthday: row[6], pickup_date: row[7],
                        vehicle_make: row[8], vehicle_model: row[9], vehicle_colour: row[10],
                        licence_plate: row[11], master_rate: row[12], weekly_rate: row[13], min_rental_period: row[14],
                        deposit: row[15], accesscode: row[16], note: row[17], user: user)
    end
  end


  def self.import_msg(file)
    contain = ''
    File.foreach(file.path).with_index do |line|
      contain = contain + line
    end
    return contain
  end


  def self.docu_auth
    host = 'https://eu.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_LIVE"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account.docusign.com'
    @private_key_filename = ENV["PRIVATE_KEY_LIVE"]
    puts ENV["PRIVATE_KEY_LIVE"]

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

  def self.convert_data(selected_envelopes)
    contain = "rowNumber,email,Rental,name,NRIC,Mailing_Address,Driver_Phone_No,Birthday,Pickup_Date,Vehicle_Make,Vehicle_Model,Vehicle_Colour,Licence_Plate,Master_Rate,Weekly_Rate,Min_Rental_Period,Deposit,Accesscode,note\n"
    counter = 1
    selected_envelopes.each do |row|
      row_new = ['"'+counter.to_s+'"','"'+row.email+'"','"'+row.rental+'"','"'+row.name+'"','"'+row.nric+'"','"'+row.mailing_address+'"','"'+row.driver_phone_no+'"','"'+row.birthday+'"','"'+row.pickup_date+'"',
                 '"'+row.vehicle_make+'"','"'+row.vehicle_model+'"','"'+row.vehicle_colour+'"','"'+row.licence_plate+'"','"'+row.master_rate+'"','"'+row.weekly_rate.to_s+'"','"'+row.min_rental_period+'"','"'+row.deposit+'"','"'+row.accesscode+'"','"'+row.note+'"']

      str1 = row_new.join(',')
      contain = contain + str1 + "\n"
      counter = counter + 1
    end
    return contain
  end

  def self.send_env(selected_envelopes,file)
    self.docu_auth # To initialize the @api_client

    t1 = DocuSign_eSign::TemplatesApi.new(@api_client)
    signer_placeholder ={"signers":[{"email":"bulk@recipient.com","name":"Bulk Recipient",
                                     "routingOrder":1,"recipientId":"1","roleName":"Hirer",
                                     "isBulkRecipient":"True"}]}
    t1.update_recipients(account_id=ENV["ACCOUNT_ID_LIVE"], template_id='714fd70c-9b78-4f05-83c1-b8e3de440867', template_recipients=signer_placeholder)
    bea = DocuSign_eSign::BulkEnvelopesApi.new(@api_client)
    bea.update_recipients(account_id=ENV["ACCOUNT_ID_LIVE"], envelope_id='714fd70c-9b78-4f05-83c1-b8e3de440867',
                          recipient_id="1",bulk_recipients_request=self.convert_data(selected_envelopes))


    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    ed = DocuSign_eSign::EnvelopeDefinition.new
    ed.template_id = '714fd70c-9b78-4f05-83c1-b8e3de440867'

    ed.brand_id = "a7acf8d2-d402-40a9-b096-52d7962cccd5" # Brand LCR Live Account
    ed.email_subject = "LCR Contract " + "[[Hirer_email]]"
    ed.email_blurb = self.import_msg(file)
    ed.status = 'sent'
    ea.create_envelope(account_id=account_id, envelope_definition=ed)

  end
end
