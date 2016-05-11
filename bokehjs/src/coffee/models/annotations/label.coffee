_ = require "underscore"
$ = require "jquery"

Annotation = require "./annotation"
ColumnDataSource = require "../sources/column_data_source"
Title = require "./title"
p = require "../../core/properties"

class LabelView extends Title.View
  initialize: (options) ->
    super(options)
    # @_initialize_properties is called by super class

  bind_bokeh_events: () ->
    if @mget('render_mode') == 'css'
      # dispatch CSS update immediately
      @listenTo(@model, 'change', @render)
      @listenTo(@mget('source'), 'change', () ->
        @set_data()
        @render())
    else
      @listenTo(@model, 'change', @plot_view.request_render)
      @listenTo(@mget('source'), 'change', () ->
        @set_data()
        @plot_view.request_render())

  _initialize_properties: () ->
    @canvas = @plot_model.get('canvas')
    @xmapper = @plot_view.frame.get('x_mappers')[@mget("x_range_name")]
    @ymapper = @plot_view.frame.get('y_mappers')[@mget("y_range_name")]

    @set_data(@mget('source'))
    @set_visuals(@mget('source'))

    @$el.addClass('bk-title-parent')

    if @mget('render_mode') == 'css'
      for i in [0...@_text.length]
        @title_div = $("<div>").addClass('bk-title-child').hide()
        @title_div.appendTo(@$el)
      @$el.appendTo(@plot_view.$el.find('div.bk-canvas-overlays'))

  _map_data: () ->
    if @mget('x_units') == "data"
      vx = @xmapper.v_map_to_target(@_x)
    else
      vx = @_x.slice(0) # make deep copy to not mutate
    sx = @canvas.v_vx_to_sx(vx)

    if @mget('y_units') == "data"
      vy = @ymapper.v_map_to_target(@_y)
    else
      vy = @_y.slice(0) # make deep copy to not mutate

    sy = @canvas.v_vy_to_sy(vy)

    return [sx, sy]

  render: () ->
    ctx = @plot_view.canvas_view.ctx

    [sx, sy] = @_map_data()

    debugger;

    if @mget('render_mode') == 'canvas'
      for i in [0...@_text.length]
        @_canvas_text(ctx, i, @_text[i], sx[i] + @_x_offset[i], sy[i] - @_y_offset[i], @_angle[i])
    else
      for i in [0...@_text.length]
        @_css_text(ctx, i, @_text[i], sx[i] + @_x_offset[i], sy[i] - @_y_offset[i], @_angle[i])

class Label extends Annotation.Model
  default_view: LabelView

  type: 'Label'

  @mixins ['text', 'line:border_', 'fill:background_']

  @define {
      x:            [ p.NumberSpec,                     ]
      x_units:      [ p.SpatialUnits, 'data'            ]
      y:            [ p.NumberSpec,                     ]
      y_units:      [ p.SpatialUnits, 'data'            ]
      text:         [ p.StringSpec,   { field: "text" } ]
      angle:        [ p.AngleSpec,    0                 ]
      x_offset:     [ p.NumberSpec,   { value: 0 }      ]
      y_offset:     [ p.NumberSpec,   { value: 0 }      ]
      source:       [ p.Instance,     () -> new ColumnDataSource.Model()  ]
      x_range_name: [ p.String,      'default'          ]
      y_range_name: [ p.String,      'default'          ]
      render_mode:  [ p.RenderMode,  'canvas'           ]
    }

  @override {
    background_fill_color: null
    border_line_color: null
  }

module.exports =
  Model: Label
  View: LabelView
