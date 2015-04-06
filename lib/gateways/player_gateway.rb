class PlayerGateway
  def self.find_by_id(player_id)
    Player.where(id: player_id).limit(1).first
  end

  def self.players_in_game(game_id)
    Player.where(game_id: game_id)
  end

  def self.find_player_in_game(game_id, user_id)
    Player.where({game_id: game_id, user_id: user_id}).first
  end

  def self.add_resources_to_player(player_id, hash)
    h = resource_hash(hash)
    player = find_by_id(player_id)
    player.gold += h[:gold]
    player.marble += h[:marble]
    player.iron += h[:iron]
    player.coins += h[:coins]
  end

  def self.subtract_resources_from_player(player_id, hash)
    h = resource_hash(hash)
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

  private

  def resource_hash(h)
    {
        gold: 0,
        marble: 0,
        iron: 0,
        coins: 0
    }.merge(h)
  end
end