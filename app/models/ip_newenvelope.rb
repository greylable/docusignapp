class IpNewenvelope < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      Ip_newenvelope.create(envelope_id: row[0], name: row[1], void_reason: row[2], user: user)
    end
  end

  def self.docu_auth
    host = 'https://demo.docusign.net/restapi'
    integrator_key = '8df67330-80dc-43c7-ab37-8d02bd7ef07f'
    user_id = 'b2a3170b-dab0-4d0d-ba2e-c7580ae92125'
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account-d.docusign.com'
    private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'

    # STEP 1: Initialize API Client
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = host

    @api_client = DocuSign_eSign::ApiClient.new(configuration)
    @api_client.configure_jwt_authorization_flow(private_key_filename, auth_server, integrator_key, user_id, expires_in_seconds)

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

  def self.allocate_tabs(array_ml,tab_label_str)
    if tab_label_str == "IP_Email"
        return array_ml[0]
    elsif tab_label_str == "NRIC"
        return array_ml[1]
    elsif tab_label_str == "IP_Name"
        return array_ml[2]
    elsif tab_label_str == "Driver_Phone_No"
        return array_ml[3]
    elsif tab_label_str == "Licence_Plate"
        return array_ml[4]
    elsif tab_label_str == "Min_Rental_Period"
        return array_ml[5]
    elsif tab_label_str == "Name_of_Bank"
        return array_ml[6]
    elsif tab_label_str == "Bank_Account_No"
        return array_ml[7]
    elsif tab_label_str == "Emergency_Name"
        return array_ml[8]
    elsif tab_label_str == "Emergency_Phone_No"
        return array_ml[9]
    elsif tab_label_str == "Vehicle_Make"
        return array_ml[10]
    elsif tab_label_str == "Vehicle_Model"
        return array_ml[11]
    elsif tab_label_str == "Pickup_Date"
        return array_ml[12]
    elsif tab_label_str == "Payee_Name"
        return array_ml[2]
    end

  def send_env(self,df_ml):
    ea = docusign.EnvelopesApi()
    ed = docusign.EnvelopeDefinition()
    ed.template_id = self.template_id
    ee = docusign.Envelope()
    t1 = docusign.TemplatesApi()

    counter = 0
    # t1_tabs = t1.get_document_tabs(account_id=self.account_id,document_id="1",template_id=self.template_id)
    # print(t1_tabs)
    for i in df_ml:
      print(i)
      counter = counter + 1
      create_env = ea.create_envelope(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4', envelope_definition=ed)
      e_id = create_env.envelope_id
      env_tabs = ea.get_document_tabs(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4',envelope_id=e_id,document_id="1")
      # create_tabs_1 = ea.create_tabs(account_id=account_id,envelope_id=e_id,recipient_id="1",tabs=t1_tabs)
      contain = []
      contain_one = []
      # print(env_tabs)
      for k in env_tabs.email_tabs:
        empty_dict_1 = {}
        empty_dict_1["value"] = self.allocate_tabs(i,k.tab_label)
        empty_dict_1["documentId"] = "1"
        empty_dict_1["tabId"] = k.tab_id
        # print(empty_dict_1)
        contain_one = contain_one + [empty_dict_1]
        for j in env_tabs.text_tabs:
          empty_dict = {}
          empty_dict["value"] = self.allocate_tabs(i,j.tab_label)
          empty_dict["documentId"] = "1"
          empty_dict["tabId"] = j.tab_id
          contain = contain + [empty_dict]
          # print(j)
          text_tabs_list = {"textTabs":contain,"emailTabs":contain_one}
          ee.email_subject = 'LCR Contract In Person ' + str(i[1])
          # ee.email_blurb = open('FRD_Eligible.txt','r').read()
          ee.status = 'sent'
          ee.brand_id = "a7acf8d2-d402-40a9-b096-52d7962cccd5" # Brand_LCR
          signer_placeholder ={"inPersonSigners":[{"hostEmail":"operations@lioncityrentals.com.sg",
                                                   "hostName":"LCR Contracts","signerName":str(i[2]),
                                                   "signerEmail":str(i[0]),
                                                   "routingOrder":1,"recipientId":"1",
                                                   "tabs":text_tabs_list}]}
          # "note":open('docusign_html.txt','r').read()
          ee.recipients = signer_placeholder
          ea.update(account_id=account_id,envelope_id=e_id,envelope=ee,advanced_update=True)
    end


  def self.send_env(selected_envelopes)
    puts self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    ee = DocuSign_eSign::Envelope.new
    selected_envelopes.each do |env|
      print(env.envelope_id.to_s)
      puts ea
      ee.status = 'voided'
      # ee.voided_reason = Voidenvelope.where # TODO: make the status column
      ee.voided_reason = 'Dear ' + env.name.to_s + ' ' + env.void_reason.to_s
      ea.update(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4',envelope_id=env.envelope_id,envelope=ee)
      # puts ea.get_form_data(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4',envelope_id=env.envelope_id)
    end
  end
end
