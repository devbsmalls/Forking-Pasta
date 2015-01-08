class EditCategoryController < UITableViewController
  extend IB

  attr_accessor :category

  outlet :saveButton, UIBarButtonItem

  def viewDidLoad
    super

    @colors = Category::COLORS
  end

  def save
    cdq.save

    self.navigationController.popViewControllerAnimated(true)
  end

  def cancel
    cdq.contexts.current.rollback   # would be great to just cdq.rollback

    self.navigationController.popViewControllerAnimated(true)
  end

  def nameDidChange(sender)
    @category.name = sender.text
    # validate
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
      cell.nameTextField.text = @category.name
      cell
    when 1
      cell = tableView.dequeueReusableCellWithIdentifier("CategoryColorCell")
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "CategoryColorCell")
      
      color = @colors[indexPath.row]
      if compareColors(@category.color, color[:value])
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

      @category.color = @colors[indexPath.row][:value]
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
      @selectedIndexPath = indexPath

      tableView.deselectRowAtIndexPath(indexPath, animated: true)

      # validate??
    end
  end

  def compareColors(c1, c2)
    cc1 = CGColorGetComponents(c1.CGColor)
    cc2 = CGColorGetComponents(c2.CGColor)
    
    value = true
    value = false if cc1[0].round(3) != cc2[0].round(3)
    value = false if cc1[1].round(3) != cc2[1].round(3)
    value = false if cc1[2].round(3) != cc2[2].round(3)

    value
  end

end