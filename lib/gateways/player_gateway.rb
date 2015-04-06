require_relative '../../app/models/player'

class PlayerGateway
  def self.find_by_id(player_id)
    Player.find(player_id).limit(1).first
  end

  def self.subtract_resources_from_player(player_id, h)
    h[:gold] ||= 0
    h[:marble] ||= 0
    h[:iron] ||= 0
    h[:coins] ||= 0
    player = find_by_id(player_id)
    raise 'not enough minerals' unless self.has_resources(player, h)
    if player.gold >= h[:gold]
      player.gold -= h[:gold]
    else
      player.coins -= (h[:gold] - player.gold)
      player.gold = 0
    end
    if player.marble >= h[:marble]
      player.marble -= h[:marble]
    else
      player.coins -= (h[:marble] - player.marble)
      player.marble = 0
    end
    if player.iron >= h[:iron]
      player.iron -= h[:iron]
    else
      player.coins -= (h[:iron] - player.iron)
      player.iron = 0
    end
    player.coins -= h[:coins]
    player.save
  end

  def has_resources(player, h)
    used_coins = h[:coins]
    used_coins += h[:gold] - player.gold
    used_coins += h[:marble] - player.marble
    used_coins += h[:iron] - player.iron
    used_coins <= player.coins
  end
end