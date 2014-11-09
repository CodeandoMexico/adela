class Admin::BaseController < ApplicationController
  layout 'application'

  before_action :set_admin_session unless Rails.env.test?
  before_action :check_admin_session unless Rails.env.test?

  def create_users
    puts "Crear usuarios"
    uploader = UsersUploader.new
    uploader.store!(file_params)
    puts "archivo cargado"
    create_users_from_file(uploader.read)
    puts "Usuarios creados desde archivo"
    if @users.any?
      redirect_to admin_root_path, :notice => "Los usuarios se crearon exitosamente."
    else
      redirect_to admin_root_path, :alert => "Ocurrió un error al crear usuarios. Verificar archivo CSV."
    end
  end

  def users
    @users = User.created_at_sorted.paginate(:page => params[:page], :per_page => 30)
  end

  def organizations
    @organizations = Organization.includes(:users).title_sorted.paginate(:page => params[:page], :per_page => 30)
  end

  def acting_as
    @user = User.find(params[:user_id])

    session[:from_admin] = true
    sign_in(@user)

    redirect_to root_path
  end

  def stop_acting_as
    session[:from_admin] = false
    sign_out(current_user)

    redirect_to admin_root_path
  end

  def set_admin_session
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['ADMIN_AUTH_NAME'] && password == ENV['ADMIN_AUTH_PASSWORD']
    end
    unless session[:admin_logs_in]
      session[:admin_logs_in] = Time.now
    end
  end

  private

  def file_params
    params.require(:csv_file)
  end

  def create_users_from_file(file_content)
    @users = []
    puts "parseando contenido del csv"
    CSV.new(file_content.force_encoding('UTF-8'), :headers => :first_row).each do |row|
      organization = Organization.where(:title => row["organizacion"]).first_or_create
      puts "consultando organizacion #{row["organizacion"]}"
      password = Devise.friendly_token.first(8)
      puts "generando password #{password}"
      user = User.new(name: row["nombre"], email: row["email"], password: password, password_confirmation: password, organization_id: organization.id)
      puts "obteniendo usuario #{row["nombre"]} #{row["email"]}"
      if user.save
        @users << user
        UserAccountWorker.perform_async(user.id, password)
        puts "creando usuario"
      end
    end
  end

  def check_admin_session
    if session[:admin_logs_in].present? && time_exceeded?
      session[:admin_logs_in] = nil
      expire_admin_session
    end
  end

  def time_exceeded?
    current_session_time = Time.now - session[:admin_logs_in].to_time
    current_session_time >= 900.seconds
  end

  def expire_admin_session
    authenticate_or_request_with_http_basic { false }
  end
end
