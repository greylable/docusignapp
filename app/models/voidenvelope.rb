class Voidenvelope < ApplicationRecord
  # has_attached_file :attachment
  belongs_to :user, required: true
  require 'csv'
  require 'docusign_esign'
  require 'uri'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      puts row[0]
      v = Voidenvelope.create(envelope_id: row[0], name: row[1], void_reason: row[2], user: user)
    end
  end

  def self.del_all(array_id)
    array_id.each do |f|
      puts f
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

  def self.void(selected_envelopes)
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

  # def create_envelope_on_document(status, is_embedded_signing)
  #   if(!$account_id.nil?)
  #     # STEP 2: Create envelope definition
  #     # Add a document to the envelope
  #     document_path = "../docs/Test.pdf"
  #     document_name = "Test.pdf"
  #     document = DocuSign_eSign::Document.new
  #     document.document_base64 = Base64.encode64(File.open(document_path).read)
  #     document.name = document_name
  #     document.document_id = '1'
  #
  #     # Create a |SignHere| tab somewhere on the document for the recipient to sign
  #     signHere = DocuSign_eSign::SignHere.new
  #     signHere.x_position = "100"
  #     signHere.y_position = "100"
  #     signHere.document_id = "1"
  #     signHere.page_number = "1"
  #     signHere.recipient_id = "1"
  #
  #     tabs = DocuSign_eSign::Tabs.new
  #     tabs.sign_here_tabs = Array(signHere)
  #
  #     signer = DocuSign_eSign::Signer.new
  #     signer.email = $recipient_email
  #     signer.name = $recipient_name
  #     signer.recipient_id = "1"
  #
  #     if(is_embedded_signing)
  #       signer.client_user_id = $client_user_id
  #     end
  #
  #     signer.tabs = tabs
  #
  #     # Add a recipient to sign the document
  #     recipients = DocuSign_eSign::Recipients.new
  #     recipients.signers = Array(signer)
  #
  #     envelop_definition = DocuSign_eSign::EnvelopeDefinition.new
  #     envelop_definition.email_subject = "[DocuSign Ruby SDK] - Please sign this doc"
  #
  #     # set envelope status to "sent" to immediately send the signature request
  #     envelop_definition.status = status.nil? ? 'sent' : status
  #     envelop_definition.recipients = recipients
  #     envelop_definition.documents = Array(document)
  #
  #     options = DocuSign_eSign::CreateEnvelopeOptions.new
  #
  #     # STEP 3: Create envelope
  #     envelopes_api = DocuSign_eSign::EnvelopesApi.new(@api_client)
  #     return envelopes_api.create_envelope($account_id, envelop_definition, options)
  #   end
  # end
end