require "ray"

def can_move_left?(pos, speed)
	(holding?(:left) || holding?(:h)) && pos.x - speed > 0
end

def can_move_right?(pos, speed)
	(holding?(:right) || holding?(:l)) && pos.x + speed + 20 < window.size.width
end

def can_move_up?(pos, speed)
	(holding?(:up) || holding?(:k)) && pos.y - speed > 0
end

def can_move_down?(pos, speed)
	(holding?(:down) || holding?(:j)) && pos.y + speed + 20 < window.size.height
end

Ray.game "Test" do
	register { add_hook :quit, method(:exit!) }

	scene :square do
		center = window.size / 2

		@music = Ray::Music.new("#{File.dirname(__FILE__)}/../sounds/Rain_Background-Mike_Koenig-1681389445.wav")
		@music.attenuation  = 0.5
    @music.min_distance = 10
    @music.pos          = [center.x, center.y, 0]
    @music.looping      = true
    @music.pitch        = 1
    @music.relative     = false
    @music.play

		@rect =  Ray::Polygon.rectangle([0, 0, 20, 20], Ray::Color.red)
		@rect.pos = [200, 200]

		max_x = window.size.width - 20
		max_y = window.size.height - 20

		@goodies = 20.times.map do
			x = rand(max_x) + 10
			y = rand(max_y) + 10

			goodie = Ray::Polygon.rectangle([0, 0, 10, 10])
			goodie.pos = [x, y]

			goodie
		end

		@badies = 5.times.map do
			x = rand(max_x) + 10
			y = rand(max_y) + 10

			baddie = Ray::Polygon.rectangle([0, 0, 15, 15], Ray::Color.blue)
			baddie.pos = [x, y]

			baddie			
		end

		always do
			speed = holding?(:lshift) ? 4 : 2
			@rect.pos += [-speed, 0] if can_move_left?(@rect.pos, speed)
			@rect.pos += [speed, 0] if can_move_right?(@rect.pos, speed)
			@rect.pos += [0, -speed] if can_move_up?(@rect.pos, speed)
			@rect.pos += [0, speed] if can_move_down?(@rect.pos, speed)

			@goodies.reject! { |g|
				goodie = [g.pos.x, g.pos.y, 10, 10].to_rect
				inside = goodie.inside?([@rect.x, @rect.y, 20, 20])

				if inside
					sound = Ray::Sound.new("#{File.dirname(__FILE__)}/../sounds/Mario_Jumping-Mike_Koenig-989896458.wav")
					sound.pos = [g.pos.x, g.pos.y, 0]
					sound.play
					sleep 0.2
				end

				inside
			}			

			@game_over ||= @badies.any? { |b|
				badie = [b.pos.x, b.pos.y, 15, 15].to_rect
				badie.collide?([@rect.pos.x, @rect.pos.y, 20, 20])
			}

			@badies.each do |b|
				if b.pos.x < @rect.pos.x
					b.pos += [rand * 2.5, 0]
				else
					b.pos -= [rand * 2.5, 0]
				end

				if b.pos.y < @rect.pos.y
					b.pos += [0, rand * 2.5]
				else
					b.pos -= [0, rand * 2.5]
				end
			end
		end

		render do |win|
			if @goodies.empty?
				win.draw text("YOU WIN", at: [100, 100], size: 60, color: Ray::Color.green)
			elsif @game_over
				win.draw text("YOU DIED (screaming!)", at: [0, 300], size: 60, color: Ray::Color.red)
				sound = Ray::Sound.new("#{File.dirname(__FILE__)}/../sounds/Strong_Punch-Mike_Koenig-574430706.wav")
				sound.play
				sleep sound.duration
			else						
				@goodies.each { |g| win.draw(g) }
				@badies.each { |b| win.draw(b) }
				win.draw(@rect)
			end
		end
	end

	scenes << :square
end