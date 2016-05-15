class AccountsController < ApplicationController
  def register
    @account = Account.new
    @all_accounts = Account.all
  end

  def create
    params.permit!
    if params[:accounts]
      required_column_names = [:account_type, :date, :content, :category, :price]
      columns = params[:accounts].slice *required_column_names
      absent_columns = [].tap do |arr|
        required_column_names.each do |key|
          arr << key unless columns[key]
        end
      end
      if absent_columns.empty?
        errors = [].tap do |array|
          array << {:error_code => 'invalid_param_account_type'} unless columns[:account_type] =~ /income|expense/
          array << {:error_code => 'invalid_param_date'} unless columns[:date] =~ /\A\d{4}-\d{2}-\d{2}\z/
          array << {:error_code => 'invalid_param_price'} unless columns[:price].to_s =~ /\A[1-9]\d*\z/
        end
        if errors.empty?
          begin
            @account = Account.create!(columns)
            if params[:from] == 'webapi'
              render :status => :created, :json => @account
            else
              render
            end
          rescue ActiveRecord::RecordInvalid => e
            errors = e.record.errors.messages.keys.map do |column|
              {:error_code => "invalid_param_#{column}"}
            end
            render :status => :bad_request, :json => errors
          end
        else
          render :status => :bad_request, :json => errors
        end
      else
        absent_columns.map!{|column| {:error_code => "absent_param_#{column}"} }
        render :status => :bad_request, :json => absent_columns
      end
    else
      render :status => :bad_request, :json => [{:error_code => 'absent_param_accounts'}]
    end
  end

  def read
    params.permit!

    result, obj = Account.show params
    if result
      render :status => :ok, :json => obj
    else
      errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
      render :status => :bad_request, :json => errors
    end
  end

  def update
    params.permit!

    if params[:with]
      result, obj = Account.update params
      if result
        render :status => :ok, :json => obj
      else
        errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
        render :status => :bad_request, :json => errors        
      end
    else
      render :status => :bad_request, :json => [{:error_code => 'absent_param_with'}]
    end
  end

  def delete
    params.permit!

    result, obj = Account.destroy params
    if result
      render :status => :no_content, :nothing => true
    else
      errors = obj.map{|param| {:error_code => "invalid_param_#{param}"} }
      render :status => :bad_request, :json => errors        
    end
  end

  def settle
    params.permit!

    if params[:interval]
      result, obj = Account.settle params[:interval]
      if result
        render :status => :ok, :json => obj
      else
        render :status => :bad_request, :json => [{:error_code => 'invalid_param_interval'}]
      end
    else
      render :status => :bad_request, :json => [{:error_code => 'absent_param_interval'}]
    end
  end
end
