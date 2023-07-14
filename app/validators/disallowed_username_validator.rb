# frozen_string_literal: true

require 'multi_string_replace'

class DisallowedUsernameValidator < ActiveModel::Validator
  DISALLOWED_USERNAMES = %w(nigger nazi).freeze
  DISALLOW_EXCEPTIONS = [[],
                         %w(ashkenazi nazionale internazionale internazionali benazir nazir nazim illuminazione
                            fluphenazine perphenazine nazionali nazione ignazio nazioni monazite nazia eskenazi
                            cyanazine ordinazione snazio nazianz nazif nazianzus nazia nazier tanazia naziah nazirah
                            nazifa janazia naziyah danazia naziya nazire nazira nazish anazia denazia lanazia nazik)].freeze

  def validate(account)
    return if account.username.blank?

    @username = account.username
    account.errors.add(:username, :disallowed) if disallowed_username?
  end

  private

  def disallowed_username?
    disallowed_matches = MultiStringReplace.match(@username.downcase, DISALLOWED_USERNAMES)
    return false if disallowed_matches.empty?

    allowed_names_to_search = disallowed_matches.keys.map { |k| DISALLOW_EXCEPTIONS[k] }.flatten
    allowable_matches = MultiStringReplace.match(@username.downcase, allowed_names_to_search)
    return true if allowable_matches.values.sum(&:size) != disallowed_matches.values.sum(&:size)

    # check that they're not hiding a disallowed username via camelcase like NaziForPresident
    # where an exception for Nazif would have been allowed
    allowable_matches.each do |k, matches|
      matches.each do |match|
        to_check = @username[match + 1, allowed_names_to_search[k].size - 1]
        return true if to_check != to_check.upcase && to_check != to_check.downcase
      end
    end
    false
  end
end
