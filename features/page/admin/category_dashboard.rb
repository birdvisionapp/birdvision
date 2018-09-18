module Page
  module Admin
    module CategoryDashboard

      def create_category row
        visit(admin_categories_path)
        if row['parent'].present?
          createSubcategory(row)
        else
          createParentCategory(row)
        end
      end

      def createParentCategory(row)
        click_on("Add New Category")
        fill_in("Category Name", :with => row["title"])
        click_button("Save")
      end

      def createSubcategory(row)
        click_on("Add New Subcategory")
        select row["parent"], :from => "category_parent_id" if row["parent"].present?
        fill_in("Subcategory Name", :with => row["title"])
        click_button("Save")
      end
    end
  end
end

World(Page::Admin::CategoryDashboard)