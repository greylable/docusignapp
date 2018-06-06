class Masterlist < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'
  # require 'tzinfo'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      Masterlist.create(envelope_id: row[0],created_time: row[1], recipient_email: row[2], status: row[3], recipient_type: row[4],
                           completed_time: row[5], declined_time: row[6], declined_reason: row[7],
                           subject_title: row[8], auth_status: row[9], auth_timestamp: row[10],
                           delivered_date_time: row[11], note: row[12], accesscode: row[13], recipient_status: row[14],rental: row[15], user: user)
    end
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

  def self.testing_only(var_1)
    var_1.each do |f|
      puts f.envelope_id
    end
  end

  def self.convert_time(utc_time)
    puts utc_time
    if utc_time.blank?
      return utc_time
    else
      time_3 = Time.zone.parse(utc_time).getlocal
      # time_4 = time_3.change(:offset => "+8000")
      # puts time_3
      return time_3
    end
  end

  def self.refresh_masterlist
    self.docu_auth
    start_date_sf = DateTime.strptime('2018-04-25 19:00:00', "%Y-%m-%d %H:%M:%S") - 15.hours
    end_date_sf = DateTime.strptime('2028-04-24 23:59:59', "%Y-%m-%d %H:%M:%S") - 15.hours

    folders_1 = DocuSign_eSign::FoldersApi.new(@api_client)
    options = DocuSign_eSign::SearchOptions.new
    options.include_recipients = "True"
    options.from_date = start_date_sf
    options.to_date = end_date_sf
    options.count = 100
    # The time is the creation time of the envelope i.e Sent time
    position = -100
    folder_items_contain = []
    while position <= 30000 do
      position = position + 100
      options.start_position = position
      folder_2 = folders_1.search(account_id=ENV["ACCOUNT_ID_LIVE"],search_folder_id="all",options).folder_items
      if folder_2.present?
        folder_items_contain = folder_items_contain + folder_2
      else
        break
      end
    end
    # return folder_items_contain
    contain = []
    folder_items_contain.each do |i|
      if i.recipients.signers != []
        e_id = i.envelope_id
        e_created_time = self.convert_time(i.created_date_time)
        e_recipient_email = i.recipients.signers[0].email
        e_status = i.status
        e_recipient_type = 'Signer'
        e_complete_time = self.convert_time(i.completed_date_time)
        e_declined_time = self.convert_time(i.recipients.signers[0].declined_date_time)
        e_declined_reason = i.recipients.signers[0].declined_reason
        e_delivered_time = self.convert_time(i.recipients.signers[0].delivered_date_time)
        e_note = i.recipients.signers[0].note
        e_accesscode = i.recipients.signers[0].access_code
        e_recipient_status = i.recipients.signers[0].status
        if i.recipients.signers[0].recipient_authentication_status.present?
          auth_status = i.recipients.signers[0].recipient_authentication_status.access_code_result.status
          auth_timestamp = self.convert_time(i.recipients.signers[0].recipient_authentication_status.access_code_result.event_timestamp)
        else
          auth_status = ''
          auth_timestamp = ''
        end
        contain = [e_id,e_created_time,e_recipient_email,e_status,e_recipient_type,e_complete_time,
                              e_declined_time,e_declined_reason,i.subject,auth_status,auth_timestamp,
                              e_delivered_time,e_note,e_accesscode,e_recipient_status]

      elsif i.recipients.in_person_signers != []
        e_id = i.envelope_id
        e_created_time = self.convert_time(i.created_date_time)
        e_recipient_email = i.recipients.in_person_signers[0].signer_email
        e_status = i.status
        e_recipient_type = 'In Person'
        e_complete_time = self.convert_time(i.completed_date_time)
        e_declined_time = self.convert_time(i.recipients.in_person_signers[0].declined_date_time)
        e_declined_reason = i.recipients.in_person_signers[0].declined_reason
        e_delivered_time = self.convert_time(i.recipients.in_person_signers[0].delivered_date_time)
        e_note = i.recipients.in_person_signers[0].note
        e_accesscode = i.recipients.in_person_signers[0].access_code
        e_recipient_status = i.recipients.in_person_signers[0].status

        if i.recipients.in_person_signers[0].recipient_authentication_status.present?
          auth_status = i.recipients.in_person_signers[0].recipient_authentication_status.access_code_result.status
          auth_timestamp = self.convert_time(i.recipients.in_person_signers[0].recipient_authentication_status.access_code_result.event_timestamp)
        else
          auth_status = ''
          auth_timestamp = ''
        end
        contain = [e_id,e_created_time,e_recipient_email,e_status,e_recipient_type,e_complete_time,
                              e_declined_time,e_declined_reason,i.subject,auth_status,auth_timestamp,
                              e_delivered_time,e_note,e_accesscode,e_recipient_status]

      end

      masterlist_search = Masterlist.where('envelope_id LIKE ?', i.envelope_id)
      # if masterlist_search is nil, append everything
      # else, update if not com,void,decline
      masterlist_search.each do |f|
        row_status = f.status
        if row_status != ('completed' or 'voided' or 'declined')
          masterlist_search.update(envelope_id: contain[0], created_time: contain[1], recipient_email: contain[2], status: contain[3], recipient_type: contain[4],
                                   completed_time: contain[5], declined_time: contain[6], declined_reason: contain[7], subject_title: contain[8], auth_status: contain[9],
                                   auth_timestamp: contain[10], delivered_date_time: contain[11], note: contain[12], accesscode: contain[13], recipient_status: contain[14])
        end
      end
    end

    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    rental_search = Masterlist.where('rental IS ? AND status IN (?)', nil, ['completed','declined','voided'])
    puts rental_search
    rental_search.each do |b|
      rental_search_env = b.envelope_id
      puts rental_search_env
      envelope_data = ea.get_form_data(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=b.envelope_id)
      form_data = envelope_data.form_data
      # puts form_data
      form_data.each do |a|
        if a.name == 'Rental' and a.value != nil
          @rental_number = a.value
        else
          @rental_number = nil
        end
      end
      # puts @rental_search_env
      b.update(envelope_id: rental_search_env, rental: @rental_number)
    end
  end
end
