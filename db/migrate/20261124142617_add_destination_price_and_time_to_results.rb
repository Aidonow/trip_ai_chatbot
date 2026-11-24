class AddDestinationPriceAndTimeToResults < ActiveRecord::Migration[8.1]
  def change
    add_column :results, :destination, :string unless column_exists?(:results, :destination)
    add_column :results, :price, :decimal, precision: 10, scale: 2 unless column_exists?(:results, :price)
    add_column :results, :time, :integer unless column_exists?(:results, :time)
  end
end
