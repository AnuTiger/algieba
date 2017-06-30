# coding: utf-8
require 'rails_helper'

describe PaymentsController, :type => :controller do
  shared_context '収支情報を検索する' do |params = {}, app_auth_header = CommonHelper.app_auth_header|
    before(:all) do
      client.header('Authorization', app_auth_header)
      @res = client.get('/payments.json', params)
      @pbody = JSON.parse(@res.body) rescue nil
    end
  end

  include_context '事前準備: クライアントアプリを作成する'
  include_context '事前準備: 収支情報を登録する'

  describe '正常系' do
    [
      [{:payment_type => 'income'}, [:income]],
      [{:date_before => '1000-01-01'}, [:income]],
      [{:date_after => '1000-01-05'}, [:expense]],
      [{:content_equal => '機能テスト用データ1'}, [:income]],
      [{:content_include => '機能テスト'}, [:income, :expense]],
      [{:category => 'algieba'}, [:income, :expense]],
      [{:price_upper => 100}, [:income, :expense]],
      [{:price_lower => 100}, [:expense]],
      [
        {
          :payment_type => 'income',
          :date_before => '1000-01-10',
          :date_after => '1000-01-01',
          :content_equal => '機能テスト用データ1',
          :content_include => '機能テスト',
          :category => 'algieba',
          :price_upper => 100,
          :price_lower => 1000,
        },
        [:income],
      ],
      [{}, [:income, :expense]],
    ].each do |query, expected_payment_types|
      description = query.empty? ? '何も指定しない場合' : "#{query.keys.join(',')}を指定する場合"
      expected_payments = expected_payment_types.map do |key|
        PaymentHelper.test_payment[key].except(:id, :category)
      end
      expected_categories = expected_payment_types.map do |key|
        PaymentHelper.test_payment[key][:category].split(',')
      end.sort

      context description do
        include_context '収支情報を検索する', query
        it_behaves_like 'ステータスコードが正しいこと', '200'
        it_behaves_like '収支情報リソースのキーが正しいこと'
        it_behaves_like 'カテゴリリソースのキーが正しいこと'
        it_behaves_like '収支情報リソースの属性値が正しいこと', expected_payments
        it_behaves_like 'カテゴリリソースの属性値が正しいこと', expected_categories
      end
    end
  end

  describe '異常系' do
    context 'Authorizationヘッダーがない場合' do
      include_context '収支情報を検索する', {}, nil
      it_behaves_like '400エラーをチェックする', ['absent_header']
    end

    context 'Authorizationヘッダーが不正な場合' do
      include_context '収支情報を検索する', {}, 'invalid'
      it_behaves_like 'ステータスコードが正しいこと', '401'
    end

    [
      {:payment_type => 'invalid_type'},
      {:date_before => 'invalid_date'},
      {:date_after => 'invalid_date'},
      {:price_upper => 'invalid_price'},
      {:price_lower => 'invalid_price'},
      {
        :payment_type => 'invalid_type',
        :date_before => 'invalid_date',
        :date_after => 'invalid_date',
        :price_upper => 'invalid_price',
        :price_lower => 'invalid_price',
      },
    ].each do |query|
      context "#{query.keys.join(',')}が不正な場合" do
        include_context '収支情報を検索する', query
        it_behaves_like '400エラーをチェックする', query.map {|key, _| "invalid_param_#{key}" }
      end
    end
  end
end
