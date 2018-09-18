Fabricator(:category) do
  title {sequence(:title) { |i| "furniture - #{i}" }    }
end

Fabricator(:sub_category_sofa, from: :category) do
  title {sequence(:title) { |i| "sofa - #{i}" }    }
end

Fabricator(:sub_category_table, from: :category) do
  title {sequence(:title) { |i| "table - #{i}" }    }
end

Fabricator(:sub_category_chair, from: :category) do
  title {sequence(:title) { |i| "chair - #{i}" }    }
end

Fabricator(:sub_category_men, from: :category) do
  title {sequence(:title) { |i| "men - #{i}" }    }
end

Fabricator(:sub_category_canon, from: :category) do
  title {sequence(:title) { |i| "Canon - #{i}" }    }
end

Fabricator(:sub_category_camera, from: :category) do
  title {sequence(:title) { |i| "Camera - #{i}" }    }
end

Fabricator(:sub_category_laptop, from: :category) do
  title {sequence(:title) { |i| "Laptop - #{i}" }    }
end

Fabricator(:sub_category_tripod, from: :category) do
  title {sequence(:title) { |i| "Tripod - #{i}" }    }
end

Fabricator(:sub_category_keyboard, from: :category) do
  title {sequence(:title) { |i| "Keyboard - #{i}" }    }
end

Fabricator(:sub_category_it, from: :category) do
  title {sequence(:title) { |i| "IT - #{i}" }    }
end

Fabricator(:sub_category_plastic, from: :category) do
title {sequence(:title) { |i| "Plastic_sub - #{i}" }    }
end
