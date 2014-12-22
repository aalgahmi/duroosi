require 'spec_helper'

feature 'Students' do
  background do
    @user = create(:user, name: 'User Joe')
    @course = create(:course)
    @klass = @course.klasses.first
    @klass.update(approved: true)
    login_as(@user, :scope => :user)
    KlassEnrollment.enroll(@klass, @user.self_student)
  end

  scenario 'can sign in' do
    visit learn_klasses_path
    expect(page).to_not have_content("Builder")
    expect(page).to have_content("Classes")
  end

  scenario 'can enroll in a class' do
    course = create(:course)
    klass = course.klasses.first
    klass.update(approved: true)
    visit learn_klasses_path

    click_link 'Learn more'
    click_link 'Enroll in this class - It\'s free'
    check('agreed')
    click_button 'Submit'

    expect(page).to have_content(course.name)
  end

  scenario 'visit class' do
    visit learn_klass_path(@klass)

    # expect(page).to have_content(course.name)
  end

  scenario 'visit class syllabus' do
    visit learn_klass_page_path(@klass, @course.syllabus)

    expect(page).to have_content('Syllabus')
  end

  # scenario 'visit class syllabus' do
  #   visit learn_klass_lecture_path(@klass)

  #   save_and_open_page
  # end

end