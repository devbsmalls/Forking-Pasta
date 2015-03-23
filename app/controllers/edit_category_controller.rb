class EditCategoryController < UITableViewController
  extend IB

  attr_accessor :category

  outlet :saveButton, UIBarButtonItem

  def viewDidLoad
    super

    @colors = Category::COLORS
    @category_name = @category.name
    @category_color_index = @category.colorIndex
  end

  def save
    self.view.endEditing(true)

    @category.name = @category_name
    @category.colorIndex = @category_color_index
    FkP.save

    self.navigationController.popViewControllerAnimated(true)
  end

  def cancel
    # do nothing, edited variables will simply be deleted

    self.navigationController.popViewControllerAnimated(true)
  end

  def nameDidChange(sender)
    @category_name = sender.text
  end

  def hideKeyboard
    self.view.endEditing(true)
  end


  #### text field delegate methods ####

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  #### table view delegate methods ####

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0
      1
    when 1
      @colors.count
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier("CategoryNameCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "CategoryNameCell")
      cell.nameTextField.delegate = self
      cell.nameTextField.text = @category_name
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("CategoryColorCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "CategoryColorCell")
      
      color = @colors[indexPath.row]
      if @category_color_index == indexPath.row
        cell.accessoryType = UITableViewCellAccessoryCheckmark
        @selectedIndexPath = indexPath
      end

      cell.colorNameLabel.text = color[:name]
      cell.colorMark.color = color[:value]
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if indexPath.section == 1
      tableView.cellForRowAtIndexPath(@selectedIndexPath).accessoryType = UITableViewCellAccessoryNone

      @category_color_index = indexPath.row
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
      @selectedIndexPath = indexPath

      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    end
  end

end