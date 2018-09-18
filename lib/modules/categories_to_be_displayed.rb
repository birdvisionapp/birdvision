module CategoriesToBeDisplayed
  def get_categories_for(level_clubs, msp_id  = nil)
    categories = Category.where("id in (select DISTINCT category_id from items i
                                INNER JOIN client_items ci on ci.item_id = i.id  AND ci.client_price IS NOT NULL AND ci.deleted = ?
                                INNER JOIN catalog_items cat_item on cat_item.client_item_id = ci.id
                                INNER JOIN level_clubs lc on cat_item.catalog_owner_id IN (?) and cat_item.catalog_owner_type = ?)", false, level_clubs, LevelClub.name)
    if msp_id.present?
      categories = categories.where(msp_id: msp_id)
    end
    @categories ||= categories.to_a
  end

  def get_parent_categories_for(level_clubs, msp_id = nil)
    @parent_categories ||= Category.where("id in (select DISTINCT ancestry from categories cat where id in (?))", get_categories_for(level_clubs, msp_id)).to_a
  end
end
