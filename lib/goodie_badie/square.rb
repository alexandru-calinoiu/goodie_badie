require "ray"

Ray.game "Test" do
	register { add_hook :quit, method(:exit!) }

	scene :square do
		@rect =  Ray::Polygon.rectangle([0, 0, 20, 20], Ray::Color.red)
		@rect.pos = [200, 200]

		always do
			speed = holding?(:lshift) ? 4 : 2
			@rect.pos += [-speed, 0] if holding?(:left) || holding?(:h)
			@rect.pos += [speed, 0] if holding?(:right) || holding?(:l)
			@rect.pos += [0, -speed] if holding?(:up) || holding?(:k)
			@rect.pos += [0, speed] if holding?(:down) || holding?(:j)
		end

		render do |win|
			win.draw(@rect)
		end
	end

	scenes << :square
end