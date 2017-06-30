# coding: utf-8
shared_context '事前準備: クライアントアプリを作成する' do
  before(:all) do
    params = {:application_id => Settings.application_id, :application_key => Settings.application_key}
    Client.create!(params)
  end

  after(:all) do
    params = {:application_id => Settings.application_id, :application_key => Settings.application_key}
    Client.find_by(params).destroy
  end
end

shared_context '事前準備: 収支情報を登録する' do |payments = PaymentHelper.test_payment.values|
  before(:all) do
    payments.each do |payment|
      category_names = payment[:category].split(',')
      categories = category_names.map {|name| Category.find_or_create_by(:name => name) }
      payment = Payment.new(payment.except(:category))
      payment.categories = categories
      payment.save!
    end
  end

  after(:all) do
    Payment.destroy_all
    Category.destroy_all
  end
end
