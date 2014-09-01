Given(/^there is a user in an archived group$/) do
  @user = FactoryGirl.create(:user, name: "Marge", email: "marge@large.org")
  @user.save!
  @group = FactoryGirl.create :group
  @membership = @group.add_member! @user
  @group.archive!
end

When(/^their group is reactivated$/) do
  @group.reactivate!
end

When(/^they sign\-in$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'password'
  click_on 'sign-in-btn'
end

Then(/^they should be able to view their group page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^any subgroups should be reactivated$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^their membership archived_at attribute should be nil$/) do
  pending # express the regexp above with the code you wish you had
end
