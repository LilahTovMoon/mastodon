# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisallowedUsernameValidator, type: :validator do
  describe '#validate' do
    before do
      validator.validate(account)
    end

    let(:validator) { described_class.new }
    let(:account)   { instance_double(Account, username: username, errors: errors) }
    let(:errors) { instance_double(ActiveModel::Errors, add: nil) }

    context 'when @username is blank?' do
      let(:username) { nil }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:username, any_args)
      end
    end

    context 'when @username is not disallowed' do
      let(:username) { 'lilah' }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:username, any_args)
      end
    end

    context 'when username is disallowed' do
      let(:username) { 'usernamenazi' }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:username, :disallowed)
      end
    end

    context 'when username is explicitly allowed' do
      let(:username) { 'ashkenazi' }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:username, any_args)
      end
    end

    context 'when only one username is explicitly allowed' do
      let(:username) { 'ashkenaziniggerashkenazi' }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:username, :disallowed)
      end
    end

    context 'when people try to hide a disallowed name via camel case' do
      let(:username) { 'NaziForPresident' } # Nazif is allowed as an Arabic name, but NaziForPresident shouldn't match

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:username, :disallowed)
      end
    end

    context 'when people try to hide a disallowed name via camel cases' do
      let(:username) { 'AshkeNazis' }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:username, :disallowed)
      end
    end

    context 'when we have an allowed username with camel case' do
      let(:username) { 'voteNazifForPresident' }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:username, any_args)
      end
    end
  end
end
