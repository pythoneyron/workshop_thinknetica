# Базовые требования
# Нужно разработать виртуальный пивной завод. У завода можно запросить нужное количество нужного пива
# Базовая объектная структурая завода должна подходить для любого конвейерного производства
# Пиво можно выпускать в банках и бутылках
# У бутылки должна быть пробка
# Любое пиво можно открыть и выпить, у него есть стоимость, которая состоит из себестоимости и стоимости упаковки
# Должна быть возможность проанализировать выпущенную заводом продукцию: посчитать общую прибыль, оценить запасы упаковки
# Упаковку нужно привозить на завод отдельно и хранить на складе
# Бутылки могут быть сданы в переработку и использоваться повторно, банки могут использоваться только один раз
# Если банку пытаются использовать повторно, конвейер должен сообщать о замене и использовать другую банку
# Проектировать завод по возможности таким образом, чтобы можно было переиспользовать код под любое конвейерное производство

require 'forwardable'

#Abstract
class PackedProduct
  attr_reader :cost, :package, :empty

  def open
    raise NotImplementedError
  end

  def open?
    raise NotImplementedError
  end

  def empty?
    empty
  end
end

class Beer < PackedProduct
  attr_reader :cost, :package, :empty, :closed

  extend Forwardable
  def_delegators :package, :open?, :open!

  def initialize
    @cost = 2
    @package = Bottle.new
    @empty = false
  end

  def drink!
    # raise if empty
    raise if empty

    # raise if closed
    raise unless open?

    @empty = true
    p "I'm now empty!"
  end
end

class Package
  attr_reader :cost, :open

  def open!
    raise NotImplementedError
  end

  def open?
    raise NotImplementedError
  end

end

class Bottle < Package
  attr_reader :cost

  def initialize
    @cap = Bottlecap.new
  end

  def open!
    # raise 'Not openable'
    @cap = nil
    # @closed = false

    p "I'm now opened!"
  end

  def open?
    @cap.nil?
  end

end

class Bottlecap
end

class Can < Package
  attr_reader :cost

  def open!
    @open = true
  end

  def open?
    @open
  end
end

class Kega < Package
end

class Container
  attr_reader :limit

  def reset_limit
    some_complex_stuff
  end

  private

  def some_complex_stuff
    # TODO: Use some value
    p 'Doing complex job...'
  end

end

class Factory
  PRODUCT_CLASS = nil

  attr_reader :produced_goods

  def initialize(name:)
    @name = name
    @produced_goods = []
  end

  # TODO: Why band?
  def produce!(quantity:, product_class: PRODUCT_CLASS)
    batch =[]

    quantity.times do
      batch << product_class.new
    end

    @produced_goods += batch

    batch
  end
end

class BeerFactory < Factory
  PRODUCT_CLASS = Beer

  def initialize
    # TODO: 
    @permissions = []

    super
  end

  def produce!(quantity:)
    batch =[]

    quantity.times do
      batch << PRODUCT_CLASS.new
    end

    @produced_goods += batch

    batch
  end
end

batch = BeerFactory.new(name: 'Sample').produce!(quantity: 9)

p batch
p batch.first.open?
p batch.first.open!
p batch.first.open?
p batch.first.drink!

