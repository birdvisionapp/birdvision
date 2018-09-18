require 'request_spec_helper'

feature "Categories Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "Should render new category page when no categories present" do
    visit(admin_categories_path)
    page.should have_content "There are no Categories yet"
    within('.actions') do
      page.should have_link "Add New Category", :href => new_admin_category_path(:type => "cat")
      page.should have_link "Add New Subcategory", :href => new_admin_category_path(:type => "subcat")
    end
  end

  scenario "Should render categories page" do
    category = Fabricate(:category)
    sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
    visit(admin_categories_path)
    page.should have_content(category.title)
    page.first(:li, ".category").first(:link)['href'].should include("type=cat")
    page.find(".subcategories-container a")['href'].should include("type=subcat")
    page.should have_content sub_category.title
  end

  it("should render subcategories in alphabetical order") do
    furniture_category = Fabricate(:category)
    Fabricate(:category,:title => "table", :ancestry => furniture_category.id)
    Fabricate(:category,:title => "sofa", :ancestry => furniture_category.id)
    visit(admin_categories_path)
    all_subcategories = page.all(".subcategories-container a")
    all_subcategories.map{|subcategory_link| subcategory_link.text}.should == ["sofa", "table"]
  end

  context "category actions" do
    scenario "Should create new category" do
      visit(admin_categories_path)
      click_on "Add New Category"
      page.should have_content 'New Category'
      page.should_not have_selector('#category_parent_id')
      fill_in('category_title', :with => 'parent')
      click_on "Save"
      within('.alert') do
        page.should have_content("The category parent was successfully created.")
      end
      page.should have_content('parent')
    end

    scenario "Should cancel create category" do
      visit(admin_categories_path)
      click_on "Add New Category"
      click_on "Cancel"
      current_url.should include(admin_categories_path)
    end

    scenario "Should not create new category if title already exists" do
      Fabricate(:category, :title => 'Furniture')
      visit(admin_categories_path)
      click_on "Add New Category"
      fill_in('category_title', :with => 'Furniture')
      click_on "Save"
      within('.alert-error') do
        page.should have_content("The title Furniture is already in use.Please enter another title")
      end
    end

    scenario "Should update a category" do
      category = Fabricate(:category)
      visit(admin_categories_path)
      click_on "furniture"
      page.should have_content 'Edit Category'
      fill_in('category_title', :with => 'parent')
      click_on "Save"
      page.should have_content 'parent'
      page.should_not have_content category.title
      within(".alert") do
        page.should have_content("The category parent was successfully updated.")
      end
    end

    scenario "Should cancel update category" do
      Fabricate(:category, :title => "furniture")
      visit(admin_categories_path)
      click_on "furniture"
      click_on "Cancel"
      current_url.should include(admin_categories_path)
    end

  end

  context "sub category actions" do
    scenario "Should create new sub category" do
      category = Fabricate(:category)
      visit(admin_categories_path)
      click_on "Add New Subcategory"
      page.should have_content 'New Subcategory'
      fill_in('category_title', :with => 'Chair')
      select("#{category.title}", :from => 'category_parent_id')
      click_on "Save"
      within('.alert') do
        page.should have_content("The sub-category Chair under #{category.title} was successfully created.")
      end
      page.should have_content('Chair')
    end

    scenario "Should cancel create category" do
      visit(admin_categories_path)
      click_on "Add New Subcategory"
      click_on "Cancel"
      current_url.should include(admin_categories_path)
    end


    scenario "Should update a sub category" do
      category1 = Fabricate(:category)
      category2 = Fabricate(:category, :title => "Home Furnishing")
      sub_category = Fabricate(:sub_category_table, :ancestry => category1.id)
      visit(admin_categories_path)
      click_on "table"
      page.should have_content 'Edit Subcategory'
      fill_in('category_title', :with => "Table Cover")
      select("#{category2.title}", :from => 'category_parent_id')
      click_on "Save"
      within('.alert') do
        page.should have_content("The sub-category Table Cover under Home Furnishing was successfully updated.")
      end
      page.should have_content "Table Cover"
      page.should_not have_content sub_category.title
    end

    scenario "Should not update a sub category if title is already taken" do
      category1 = Fabricate(:category)
      category2 = Fabricate(:category, :title => "Home Furnishing")
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category1.id)
      sub_category_table = Fabricate(:sub_category_table, :ancestry => category2.id)

      visit(admin_categories_path)

      click_on "sofa"
      fill_in('category_title', :with => sub_category_table.title)
      click_on "Save"
      within(".alert-error") do
        page.should have_content("The title #{sub_category_table.title} is already in use.Please enter another title")
      end
    end

    scenario "Should cancel update category" do
      category = Fabricate(:category, :title => "furniture")
      Fabricate(:category, :title => "sofa", :ancestry => category.id)

      visit(admin_categories_path)
      click_on "sofa"
      click_on "Cancel"
      current_url.should include(admin_categories_path)
    end

  end

end