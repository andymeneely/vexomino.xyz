def tick args

  if args.inputs.mouse.position
    args.outputs.sprites << [args.inputs.mouse.position.x, args.inputs.mouse.position.y, 128, 101, 'dragonruby.png']
  else
    args.outputs.sprites << [576, 280, 128, 101, 'dragonruby.png']
  end

end
