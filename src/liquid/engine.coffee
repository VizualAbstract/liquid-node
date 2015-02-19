Liquid = require "../liquid"
Promise = require "bluebird"

module.exports = class Liquid.Engine
  constructor: (fileSystem) ->
    @tags = {}
    @Strainer = (@context) ->
    @registerFilters Liquid.StandardFilters

    isSubclassOf = (klass, ofKlass) ->
      unless typeof klass is 'function'
        false
      else if klass == ofKlass
        true
      else
        isSubclassOf klass.__super__?.constructor, ofKlass

    # Assign the passed FileSystem instance or create a new one
    if isSubclassOf fileSystem, Liquid.LocalFileSystem
      @fileSystem = fileSystem
    else
      @fileSystem = new Liquid.LocalFileSystem "./"

    for own tagName, tag of Liquid
      continue unless isSubclassOf(tag, Liquid.Tag)
      isBlockOrTagBaseClass = [Liquid.Tag, Liquid.Block].indexOf(tag.constructor) >= 0
      @registerTag tagName.toLowerCase(), tag unless isBlockOrTagBaseClass

  registerTag: (name, tag) ->
    @tags[name] = tag

  registerFilters: (filters...) ->
    filters.forEach (filter) =>
      for own k, v of filter
        @Strainer::[k] = v if v instanceof Function

  parse: (source) ->
    template = new Liquid.Template
    template.parse @, source

  parseAndRender: (source, args...) ->
    @parse(source).then (template) ->
      template.render(args...)
