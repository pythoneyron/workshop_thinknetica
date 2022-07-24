class Conveyor
  def produce(product:, quantity:, package_source:)


    quantity.times do
      batch << product_class.new(package: package)
    end
  end
end
 