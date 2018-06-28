class Masterlist < ApplicationRecord
  belongs_to :user, required: false
  require 'csv'
  require 'base64'
  require 'matrix'


  # require 'tzinfo'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true, encoding: 'iso-8859-1:utf-8') do |row|
      Masterlist.create(envelope_id: row[0],created_time: row[1], recipient_email: row[2], status: row[3], recipient_type: row[4],
                           completed_time: row[5], declined_time: row[6], declined_reason: row[7],
                           subject_title: row[8], auth_status: row[9], auth_timestamp: row[10],
                           delivered_date_time: row[11], note: row[12], accesscode: row[13], recipient_status: row[14],rental: row[15], user: user)
    end
  end

  def self.to_csv
    attributes = %w{envelope_id	created_time recipient_email status recipient_type completed_time declined_time	declined_reason	subject_title	auth_status	auth_timestamp delivered_date_time note	accesscode recipient_status rental}
    CSV.generate(headers: true) do |csv|

      csv << attributes
      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end


  def self.docu_auth
    host = 'https://eu.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_LIVE"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account.docusign.com'
    @private_key_filename = ENV["PRIVATE_KEY_LIVE"]
    # puts ENV["PRIVATE_KEY_LIVE"]

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

  def self.get_doc(i)
    # self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    file_contents = ea.get_document(account_id=ENV["ACCOUNT_ID_LIVE"], recipient_id="1", envelope_id=i.envelope_id)
    fileName = 'Rental_' + i.rental.to_s + '_Envelope_' + i.envelope_id.to_s
    base64_doc = Base64.encode64(File.open(file_contents, "rb").read).encode('iso-8859-1').force_encoding('utf-8')
    decoded_doc = Base64.decode64(base64_doc)
    return [fileName,decoded_doc]
  end

  def self.testing_only(var_1)
    var_1.each do |f|
      puts f.envelope_id
    end
  end

  def self.convert_time(utc_time)
    # puts utc_time
    if utc_time.blank?
      return utc_time
    else
      time_3 = Time.zone.parse(utc_time) #+ 8*60*60 #.getlocal
      # time_4 = time_3.change(:offset => "+8000")
      # puts time_3
      return time_3.strftime("%Y-%m-%d %H:%M:%S")
    end
  end

  def self.refresh_masterlist
    self.docu_auth

    # Fetch Envelope Data from Docusign API
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
    while position <= 100000 do
      position = position + 100
      options.start_position = position
      folder_2 = folders_1.search(account_id=ENV["ACCOUNT_ID_LIVE"],search_folder_id="all",options).folder_items
      if folder_2.present?
        folder_items_contain = folder_items_contain + folder_2
      else
        break
      end
    end
    puts folder_items_contain.length
    # return folder_items_contain
    contain = []
    folder_items_contain.each do |i|
      if i.recipients.signers != [] and i.subject.include? 'LCR Contract'
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

      elsif i.recipients.in_person_signers != [] and i.subject.include? 'LCR Contract'
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

      # Updating Masterlist (Case 1, Case 2)
      masterlist_search = Masterlist.where('envelope_id LIKE ?', i.envelope_id)
      # if masterlist_search is nil, append everything
      if masterlist_search.present? and e_id.present?
        masterlist_search.each do |f|
          row_status = f.status
          if row_status != ('completed' or 'voided' or 'declined')
            # puts row_status
            masterlist_search.update(envelope_id: contain[0], created_time: contain[1], recipient_email: contain[2], status: contain[3], recipient_type: contain[4],
                                     completed_time: contain[5], declined_time: contain[6], declined_reason: contain[7], subject_title: contain[8], auth_status: contain[9],
                                     auth_timestamp: contain[10], delivered_date_time: contain[11], note: contain[12], accesscode: contain[13], recipient_status: contain[14])
          end
        end

      # else, Updating Masterlist if the "Old" status is not Com/Void/Decline
      else
        if masterlist_search.blank? and contain[3] != ('created' or 'template') and e_id.present?
          Masterlist.create(envelope_id: contain[0], created_time: contain[1], recipient_email: contain[2], status: contain[3], recipient_type: contain[4],
                            completed_time: contain[5], declined_time: contain[6], declined_reason: contain[7], subject_title: contain[8], auth_status: contain[9],
                            auth_timestamp: contain[10], delivered_date_time: contain[11], note: contain[12], accesscode: contain[13], recipient_status: contain[14])
        end
      end
    end

    # Update Rental Number Only #
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    rental_search = Masterlist.where('rental IS ? AND status IN (?)', nil, ['completed','declined','voided'])
    puts rental_search
    rental_search.each do |b|
      rental_search_env = b.envelope_id
      puts rental_search_env
      envelope_data = ea.get_form_data(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=b.envelope_id)
      form_data = envelope_data.form_data
      form_data.each do |a|
        if a.name == 'Rental' #and a.value != nil
          @rental_number = a.value
        end
      end
      b.update(envelope_id: rental_search_env, rental: @rental_number)
    end
  end

  def self.g_authorize

    require 'google/apis/sheets_v4'
    require 'googleauth'
    require 'googleauth/stores/file_token_store'
    require 'fileutils'

    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials

    @OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    @CLIENT_SECRETS_PATH = ActiveSupport::JSON.decode(ENV["CLIENT_SECRET"]).freeze
    @CREDENTIALS_PATH = ENV["TOKEN_YAML_FILE"].freeze
    @SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

    client_id = Google::Auth::ClientId.from_hash(@CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: @CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, @SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: @OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
         'resulting code after authorization:\n' + url
      code = ENV["GSHEETS_CODE"]
      credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: @OOB_URI
      )
    end
    credentials
  end

  def self.dedupe(array_2d,col)
    contain = []
    seen = []
    array_2d.each do |i|
      if (seen.index i[col])
        next
      else
        contain = contain + [i]
        seen = seen + Array(i[col])
      end
    end
    return contain
  end

  def self.update_env_masterlist
    # Update Envelopes_Masterlist
    env_masterlist = Masterlist.where.not('status IN (?)', ['created','template'])
    env_masterlist_2 = env_masterlist.order(:created_time)
    env_masterlist_3 = env_masterlist_2.pluck(:envelope_id,	:created_time,	:recipient_email,	:status,	:recipient_type,	:completed_time,	:declined_time,
                                :declined_reason,	:subject_title,	:auth_status,	:auth_timestamp,	:delivered_date_time,	:note,	:accesscode,	:recipient_status,	:rental)
    return self.dedupe(env_masterlist_3,0)
  end

  def self.update_unique_ml(array_env_masterlist)
    raw_data = array_env_masterlist.select{|u| u[15].present? and u[15].downcase.exclude? 'test'}
    # Completed Env: Take latest completed_time and dedupe
    completed_env = raw_data.select{|u| u[3] == 'completed'}
    completed_env_sort = completed_env.sort{|a,b| b[5] <=> a[5]}
    completed_env_final = self.dedupe(completed_env_sort,15) ## TAKE THIS ##
    completed_env_final_list = completed_env_final.map {|row| row[15]}

    # Declined Env:
    declined_env = raw_data.select{|u| u[3] == 'declined'}
    # Declined not in completed
    declined_env_1 = declined_env.select{|u| completed_env_final_list.exclude?(u[15])}
    declined_env_sort = declined_env_1.sort{|a,b| b[6] <=> a[6]}
    declined_env_final = self.dedupe(declined_env_sort,15) ## TAKE THIS ##
    declined_env_final_list = declined_env_final.map {|row| row[15]}

    # Completed + Decline =
    combine_list = completed_env_final_list + declined_env_final_list

    # Rest of Env:
    # Not in combine_list, not completed nor declined
    others_env = raw_data.select{|u| u[3] != 'completed' or u[3] != 'declined'}
    others_env_1 = others_env.select{|u| combine_list.exclude?(u[15])}
    others_env_sort = others_env_1.sort{|a,b| b[1] <=> a[1]}
    others_env_final = self.dedupe(others_env_sort,15) ## TAKE THIS ##

    # Final Data = Completed + Declined + Rest Env
    final_data = completed_env_final + declined_env_final + others_env_final
    return final_data
  end

  def self.g_get_data(range)
    require 'google/apis/sheets_v4'
    require 'googleauth'
    require 'googleauth/stores/file_token_store'
    require 'fileutils'

    @APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze

    # Initialize the API
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = @APPLICATION_NAME
    service.authorization = self.g_authorize

    spreadsheet_id = ENV["SPREADSHEET_ID"]
    response = service.get_spreadsheet_values(spreadsheet_id, range)
    return response.values.flatten
  end

  def self.envelope_inperson_details(envelope_uuid)
    envelope_instance = DocuSign_eSign::EnvelopesApi.new(@api_client)
    envelope_data = envelope_instance.get_form_data(ENV["ACCOUNT_ID_LIVE"],envelope_uuid)
    form_data = envelope_data.form_data # Can have more than 1 NameValue pair
    e_id = envelope_data.envelope_id
    empty_dict = {}
    form_data.each do |j|
      empty_dict[j.name] = j.value
    end
    if empty_dict['Bank_Account_No'].present?
      empty_dict['Bank_Account_No'] = "'"+empty_dict['Bank_Account_No']
    end
    header_list = ['Rental','IP_Email','IP_Name','NRIC','Mailing_Address','Driver_Phone_No','Birthday','Pickup_Date','Vehicle_Make','Vehicle_Model','Vehicle_Colour',
                   'Licence_Plate','Master_Rate','Weekly_Rate','Min_Rental_Period','Deposit','Payee_Name','Name_of_Bank','Bank_Address','Bank_Account_No','Bank_Code',
                   'Branch_Code','Swift_Code','Hirer_PDPA','Driver_Licence_No','Expiration_Date','Driver_Licence_Class','Emergency_Name','Emergency_NRIC',
                   'Emergency_Mailing_Address','Emergency_Email','Emergency_Phone_No','Emergency_Birthday','Grab_Checkbox']
    contain_value = []
    header_list.each do |h|
      begin
        col_1 = empty_dict[h]
      rescue
        col_1 = ''
      end
      contain_value = contain_value + [col_1]
    end
    contain_value_all = [e_id]+ contain_value
    return contain_value_all
  end

  def self.update_com_ip(array_env_masterlist)
    # Get Completed Env from Gsheets Completed IP
    com_env_ip_list = self.g_get_data('App Com IP!A2:A')
    com_env_ip_list_next_row = com_env_ip_list.length+2
    # Get current_completed_ip
    raw_data = array_env_masterlist.select{|u| u[15].present? and u[15].downcase.exclude? 'test'}
    completed_env = raw_data.select{|u| u[3] == 'completed' and u[4] == 'In Person'}
    current_com_env_ip_list = completed_env.map {|row| row[0]}
    # In Current but not in Gsheets
    diff_list = current_com_env_ip_list-com_env_ip_list

    # Iterate through diff_list to get Envelope Details from Docusign
    self.docu_auth
    contain_all = []
    diff_list.each do |f|
      contain_all = contain_all + [self.envelope_inperson_details(f)]
    end
    return [com_env_ip_list_next_row,contain_all.length,contain_all]
  end

  def self.envelope_signer_details(envelope_uuid)
    envelope_instance = DocuSign_eSign::EnvelopesApi.new(@api_client)
    envelope_data = envelope_instance.get_form_data(ENV["ACCOUNT_ID_LIVE"],envelope_uuid)
    form_data = envelope_data.form_data # Can have more than 1 NameValue pair
    e_id = envelope_data.envelope_id
    empty_dict = {}
    form_data.each do |j|
      empty_dict[j.name] = j.value
    end
    if empty_dict['Bank_Account_No'].present?
      empty_dict['Bank_Account_No'] = "'"+empty_dict['Bank_Account_No']
    end
    header_list = ["Rental","Email","NRIC","Payee_Name","Name_of_Bank","Bank_Address","Bank_Account_No",
                   "Bank_Code","Branch_Code","Swift_Code","Hirer_PDPA","Mailing_Address","Driver_Licence_No",
                   "Expiration_Date","Driver_Licence_Class","Emergency_Name","Emergency_NRIC",
                   "Emergency_Mailing_Address","Emergency_Email","Emergency_Phone_No","Emergency_Birthday",
                   "Grab_Checkbox"]
    contain_value = []
    header_list.each do |h|
      begin
        col_1 = empty_dict[h]
      rescue
        col_1 = ''
      end
      contain_value = contain_value + [col_1]
    end
    contain_value_all = [e_id]+ contain_value
    return contain_value_all
  end

  def self.update_com_signer(array_env_masterlist)
    # Get Completed Env from Gsheets Completed Bulk
    com_env_signer_list = self.g_get_data('App Com Bulk!A2:A')
    com_env_signer_list_next_row = com_env_signer_list.length+2
    # Get current_completed_signer
    raw_data = array_env_masterlist.select{|u| u[15].present? and u[15].downcase.exclude? 'test'}
    completed_env = raw_data.select{|u| u[3] == 'completed' and u[4] == 'Signer'}
    current_com_env_signer_list = completed_env.map {|row| row[0]}
    # In Current but not in Gsheets
    diff_list = current_com_env_signer_list-com_env_signer_list

    # Iterate through diff_list to get Envelope Details from Docusign
    self.docu_auth
    contain_all = []
    diff_list.each do |f|
      contain_all = contain_all + [self.envelope_signer_details(f)]
    end
    return [com_env_signer_list_next_row,contain_all.length,contain_all]
  end

  def self.g_update
    require 'google/apis/sheets_v4'
    require 'googleauth'
    require 'googleauth/stores/file_token_store'
    require 'fileutils'

    @APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze

    # Initialize the API
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = @APPLICATION_NAME
    service.authorization = self.g_authorize

    spreadsheet_id = ENV["SPREADSHEET_ID"]

    request_body_del = Google::Apis::SheetsV4::BatchClearValuesRequest.new
    request_body_del.ranges = ['App Masterlist!A2:P','App Unique!A2:P']
    service.batch_clear_values(spreadsheet_id, request_body_del)
    envelopes_masterlist = self.update_env_masterlist
    com_ip = self.update_com_ip(envelopes_masterlist)
    com_signer = self.update_com_signer(envelopes_masterlist)
    unique_ml = self.update_unique_ml(envelopes_masterlist)


    value_range_object_1 = {
        major_dimension: "ROWS",
        range: 'App Masterlist!A2:P',
        values: envelopes_masterlist
    }
    value_range_object_2 = {
        major_dimension: "ROWS",
        range: 'App Unique!A2:P',
        values: unique_ml
    }

    data = [value_range_object_1,value_range_object_2]

    if com_ip[1] != 0
      batch_update_spreadsheet_request_1 = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new
      batch_update_spreadsheet_request_1.requests = [
        {append_dimension: {
            sheet_id: ENV["COM_IP_SHEET_ID"],
            dimension: 'ROWS',
            length: com_ip[1]
          }
        }
      ]
      service.batch_update_spreadsheet(spreadsheet_id, batch_update_spreadsheet_request_1)

      value_range_object_3 = {
          major_dimension: "ROWS",
          range: 'App Com IP!A'+com_ip[0].to_s+':AI',
          values: com_ip[2]
      }
      data = data + [value_range_object_3]
    end

    if com_signer[1] != 0
      batch_update_spreadsheet_request_2 = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new
      batch_update_spreadsheet_request_2.requests = [
        {append_dimension: {
            sheet_id: ENV["COM_SIGNER_SHEET_ID"],
            dimension: 'ROWS',
            length: com_signer[1]
          }
        }
      ]
      service.batch_update_spreadsheet(spreadsheet_id, batch_update_spreadsheet_request_2)

      value_range_object_4 = {
          major_dimension: "ROWS",
          range: 'App Com Bulk!A'+com_signer[0].to_s+':W',
          values: com_signer[2]
      }
      data = data + [value_range_object_4]
    end

    request_body = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new
    request_body.value_input_option = "user_entered"
    request_body.data = data

    service.batch_update_values(spreadsheet_id, request_body)
  end
end