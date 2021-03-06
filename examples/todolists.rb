# frozen_string_literal: true

require 'camper'

client = Camper.client

projects = client.projects

projects.auto_paginate do |p|
  puts "Project: #{p.name}"

  todoset = client.todoset(p)

  puts "Ratio of completed Todos in Todoset: #{todoset.completed_ratio}"

  puts 'Listing active todolists'
  client.todolists(todoset).auto_paginate(5) do |list|
    puts "Todolist: #{list.title}"

    client.todos(list).auto_paginate do |todo|
      puts "Todo: #{todo.title}"
      puts "Get Todo using project id: #{client.todo(p.id, todo.id).title}"
      puts "Get Todo using project resource: #{client.todo(p, todo.id).title}"
      puts "Get Todo using todolist resource: #{client.todo(list, todo.id).title}"
    end
  end

  begin
    client.todolists(p)
  rescue Camper::Error::InvalidParameter, NoMethodError
    puts 'Cannot use a project p to get the todolists'
  end

  puts 'Listing archived todolists'
  client.todolists(todoset, status: :archived).auto_paginate do |list|
    client.todos(list).auto_paginate do |todo|
      puts "Todo: #{todo.title}"
      puts "Can be commented: #{todo.can_be_commented?}"
      puts "It's completed: #{todo.completed}"

      client.complete_todo(todo)
    end
  end

  puts 'Create a new todolist'
  new_list = client.create_todolist(todoset, 'Temporary list')
  puts "Todolist title: #{new_list.title}"
  puts 'Trash list'
  client.trash_todolist(new_list)
end