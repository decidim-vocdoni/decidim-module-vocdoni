# frozen_string_literal: true

shared_examples "doesn't allow to vote" do
  it "doesn't allow clicking in the vote button" do
    visit router.election_path(id: election.id)

    expect(page).to have_no_link("Vote")
  end

  it "doesn't allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

shared_examples "allows admins to preview the voting booth" do
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  before do
    visit router.election_path(id: election.id)
    puts election.id
    puts election.questions.count
    puts election.questions.first.answers.first.title
    puts election.questions.first.answers.last.title
    click_link_or_button "Preview"
  end

  it { uses_the_voting_booth({ email: user.email, token: "123456" }) }

  it "shows the preview alert" do
    expect(page).to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "doesn't allow admins to preview the voting booth" do
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  it "doesn't allow clicking the preview button" do
    visit router.election_path(id: election.id)

    expect(page).to have_no_link("Preview")
  end

  it "doesn't allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

def uses_the_voting_booth(census_data)
  selected_answers = []
  non_selected_answers = []

  login_step(census_data)

  # shows a yes/no/abstention question: radio buttons, no random order, no extra information
  question_step(1) do |question|
    expect_not_valid

    select_answers(question, 1, selected_answers, non_selected_answers)
  end

  # confirm step
  non_question_step("#step-1") do
    expect(page).to have_content("Confirm your vote")

    selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
    non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

    within "#edit-step-1" do
      click_link_or_button("edit")
    end
  end

  # edit step 2
  question_step(1) do |question|
    change_answer(question, selected_answers, non_selected_answers)
  end

  # confirm step
  non_question_step("#step-1") do
    expect(page).to have_content("CONFIRM YOUR VOTE")

    selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
    non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

    click_link_or_button("Confirm")
  end

  # confirmed vote page
  sleep 2 # wait for the setTimeout in preview
  expect(page).to have_content("Your vote has been cast successfully")
end

def login_step(census_data)
  within "#check_census" do
    fill_in :login_email, with: census_data.fetch(:email)
    fill_in :login_token, with: census_data.fetch(:token)

    click_link_or_button "Access"
  end
end

def question_step(number)
  expect_only_one_step
  expect(page).to have_content("QUESTION #{number} OF 1")
  within "#step-#{number - 1}" do
    question = election.questions[number - 1]

    expect(page).to have_i18n_content(question.title)

    yield question if block_given?

    click_link_or_button("Next")
  end
end

def non_question_step(id)
  expect_only_one_step
  within id do
    yield
  end
end

def select_answers(question, number, selected, non_selected)
  answers = question.answers.to_a
  number.times do
    answer = answers.delete(answers.sample)
    selected << answer
    if number == 1
      choose(translated(answer.title), allow_label_click: true)
    else
      check(translated(answer.title), allow_label_click: true)
    end
  end
  non_selected.concat answers
end

def change_answer(question, selected, non_selected)
  new_answer = question.answers.select { |answer| non_selected.member?(answer) }.first
  old_answer = question.answers.select { |answer| selected.member?(answer) }.first

  selected.delete(old_answer)
  non_selected << old_answer
  non_selected.delete(new_answer)
  choose(translated(new_answer.title), allow_label_click: true)
  selected << new_answer
end

def expect_only_one_step
  expect(page).to have_css(".focus__step", count: 1)
end

def expect_not_valid
  expect(page).to have_no_link("Next")
end

def expect_valid
  expect(page).to have_link("Next")
end
