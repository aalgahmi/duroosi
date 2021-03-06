module Admin
  class AccountsController < BaseController
    include WithSettings
    responders :modal, :flash, :http_cache
    before_action :set_account, only: [:show, :edit, :update, :destroy, :settings, :configure]

    def index
      @q = Account.search(params[:q])
      @accounts = @q.result.page(params[:page]).per(10)

      respond_with(@accounts)
    end

    def show
      respond_with(@account)
    end

    def new
      @account = Account.new(:user => User.new)
      config = YAML.load_file("#{Rails.root}/config/config-account.yml")
      @account.settings = JSON.pretty_generate(config['account'])
      respond_with(@account)
    end

    def edit
    end

    def create
      @account = Account.new(account_params)
      if @account.save
        config = YAML.load_file("#{Rails.root}/config/config-account.yml")
        $redis.set "config.account.a#{@account.id}", config['account'].to_json
      end

      respond_with(:admin, @account)
    end

    def update
      if account_params[:live] && @account.live_since.blank?
        @account.live_since = Time.zone.now
      end

      @account.update(account_params.reject { |k,v| k.to_s == 'user_attributes' })
      respond_with(:admin, @account)
      # if current_user.id == @account.user_id
      #   redirect_to home_path, :notice => t('flash.actions.update.notice', :resource_name => Account.model_name.human)
      # else
      #   respond_with(:admin, @account)
      # end
    end

    def settings
    end
    
    def configure
      do_configure(@account.config, "config.account.a#{@account.id}",  settings_admin_account_path(@account))
    end

    def destroy
      if @account.slug != $site['default_account']
        @account.destroy
        $redis.del "config.account.a#{@account.id}"
      end

      respond_with(:admin, @account)
    end

    private
      def set_account
        @account = Account.find(params[:id])
        @account.config = JSON.parse($redis.get("config.account.a#{@account.id}"))
        @account.settings = JSON.pretty_generate(@account.config)
      end

      def account_params
        params.require(:account).permit(:slug, :name, :about, :settings, :active, :live, :live_since,
          :user_attributes => [ :email, :name, :password, :password_confirmation ]
        )
      end
  end
end
