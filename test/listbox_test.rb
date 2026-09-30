# frozen_string_literal: true

require 'minitest/autorun'
require 'weakref'
require 'test_helper'
require 'newt'

class TestListbox < Minitest::Test
  def setup
    Newt.init
    @lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      @lb.append("item#{i}", i)
    end
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::Listbox.new(0, 0, 0)
  end

  def test_get_curent
    @lb.set_current(2)
    assert_equal(3, @lb.get_current)
  end

  def test_get_current_empty_list
    lb = Newt::Listbox.new(0, 0, 0)
    assert_equal(false, lb.get_current)
  end

  def test_get_current_string
    lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      lb.append("item#{i}", "String no. #{i}")
    end
    lb.set_current(2)
    assert_equal('String no. 3', lb.get_current)
  end

  def test_set_current
    rnd = rand(1000)
    @lb.set_data(3, rnd)
    @lb.set_current(3)
    assert_equal(rnd, @lb.get_current)
  end

  def test_set_current_by_key
    @lb.set_current_by_key(3)
    assert_equal(3, @lb.get_current)
  end

  def test_set_width
    @lb.set_width(20)
    size = @lb.get_size
    assert_equal(size[0], 20)
  end

  def test_set_data
    @lb.set_data(2, 10)
    assert_equal(['item3', 10], @lb.get(2))
  end

  def test_retained_values_are_not_exposed_as_instance_variables
    @lb.append('temporary', Object.new)
    refute(@lb.instance_variable_defined?(:@newt_ivar_data))
  end

  def test_set_data_releases_replaced_value
    weak_data = set_data_with_weakref(0)
    GC.start
    assert(weak_data.weakref_alive?)

    @lb.set_data(0, 100)
    GC.start
    refute(weak_data.weakref_alive?)
  end

  def test_set_data_does_not_duplicate_retained_value
    weak_data = set_data_with_weakref(0, 2)
    GC.start
    assert(weak_data.weakref_alive?)

    @lb.set_data(0, 100)
    GC.start
    refute(weak_data.weakref_alive?)
  end

  def test_append
    @lb.append('item6', 6)
    assert_equal(['item6', 6], @lb.get(5))
  end

  def test_add_unusual_data
    time = Time.now
    @lb.append('item6', time)
    @lb.set_current(5)
    assert_equal(time, @lb.get_current)
  end

  def test_insert
    assert_equal(5, @lb.item_count)
    @lb.insert('inserted', 100, 3)
    assert_equal(6, @lb.item_count)
  end

  def test_get
    assert_equal(['item3', 3], @lb.get(2))
  end

  def test_get_rejects_out_of_range_indexes
    assert_raises(IndexError) { @lb.get(-1) }
    assert_raises(IndexError) { @lb.get(@lb.item_count) }
  end

  def test_set
    @lb.set(2, 'newitem3')
    assert_equal(['newitem3', 3], @lb.get(2))
  end

  def test_delete
    @lb.delete(4)
    @lb.delete(2)
    assert_equal(3, @lb.item_count)
  end

  def test_delete_by_data
    data = Object.new
    @lb.append('temporary', data)

    @lb.delete(data)
    assert_equal(5, @lb.item_count)
  end

  def test_clear
    assert_equal(5, @lb.item_count)
    @lb.clear
    assert_equal(0, @lb.item_count)
  end

  def test_clear_releases_data
    weak_data = append_data_with_weakref
    GC.start
    assert(weak_data.weakref_alive?)

    @lb.clear
    GC.start
    refute(weak_data.weakref_alive?)
  end

  def test_get_selection
    @lb.select(2, Newt::FLAGS_SET)
    @lb.select(5, Newt::FLAGS_SET)
    assert_equal([2, 5], @lb.get_selection.sort)
  end

  def test_clear_selection
    @lb.select(2, Newt::FLAGS_SET)
    @lb.select(5, Newt::FLAGS_SET)
    assert_equal([2, 5], @lb.get_selection.sort)

    @lb.clear_selection
    assert_equal([], @lb.get_selection)
  end

  def test_select
    @lb.select(2, Newt::FLAGS_SET)
    assert_equal([2], @lb.get_selection.sort)
  end

  def test_item_count
    assert_equal(5, @lb.item_count)

    rnd = rand(7..20)
    6.upto(rnd) do |i|
      @lb.append("item#{i}", nil)
    end
    assert_equal(rnd, @lb.item_count)
  end

  private

  def set_data_with_weakref(index, repeats = 1)
    data = Object.new
    weak_data = WeakRef.new(data)
    repeats.times { @lb.set_data(index, data) }
    weak_data
  end

  def append_data_with_weakref
    data = Object.new
    weak_data = WeakRef.new(data)
    @lb.append('temporary', data)
    weak_data
  end
end

class TestListboxUninitialized < Minitest::Test
  def setup
    Newt.init
    @lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      @lb.append("item#{i}", i)
    end
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Listbox.new(0, 0, 0)
    end
  end

  def test_get_curent
    assert_init_exception do
      @lb.get_current
    end
  end

  def test_set_current
    assert_init_exception do
      @lb.set_current(3)
    end
  end

  def test_set_current_by_key
    assert_init_exception do
      @lb.set_current_by_key(3)
    end
  end

  def test_set_width
    assert_init_exception do
      @lb.set_width(20)
    end
  end

  def test_set_data
    assert_init_exception do
      @lb.set_data(2, 10)
    end
  end

  def test_append
    assert_init_exception do
      @lb.append('item6', 6)
    end
  end

  def test_insert
    assert_init_exception do
      @lb.insert('inserted', 100, 3)
    end
  end

  def test_get
    assert_init_exception do
      @lb.get(2)
    end
  end

  def test_set
    assert_init_exception do
      @lb.set(2, 'newitem3')
    end
  end

  def test_delete
    assert_init_exception do
      @lb.delete(4)
    end
  end

  def test_clear
    assert_init_exception do
      @lb.clear
    end
  end

  def test_get_selection
    assert_init_exception do
      @lb.select(2, Newt::FLAGS_SET)
    end
  end

  def test_clear_selection
    assert_init_exception do
      @lb.clear_selection
    end
  end

  def test_select
    assert_init_exception do
      @lb.select(2, Newt::FLAGS_SET)
    end
  end
end
