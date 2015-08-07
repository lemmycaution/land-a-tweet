class AlterJsonbToJsonAndBack < ActiveRecord::Migration  
  def up
    change_column :donors, :payload, 'jsonb USING CAST(payload AS jsonb)'  
  end

  def down
    change_column :donors, :payload, 'json USING CAST(payload AS json)'
  end
end      