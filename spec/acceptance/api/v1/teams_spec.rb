require "rails_helper"

RSpec.describe "Teams", { type: :request } do
  describe "SHOW" do
    let(:team) { Team.first }

    it "includes base team attributes" do
      get "/api/v1/teams/#{team.id}"
      expect(response).to be_success
      expect(json_body["team"]["id"]).to eq(team.id)
      expect(json_body["team"]["title"]).to eq(team.title)
      expect(json_body["team"]["roster_slot_ids"].size).to eq(team.roster_slots.size)
    end

    it "includes roster_slots" do
      get "/api/v1/teams/#{team.id}"
      expect(response).to be_success
      expect(json_body["roster_slots"].size).to eq(team.roster_slots.size)
      expect(json_body["roster_slots"][0]["id"]).to be
      expect(json_body["roster_slots"][0]["league_player_id"]).to be
      expect(json_body["roster_slots"][0]["league_position_id"]).to be
    end

    it "includes league_players" do
      get "/api/v1/teams/#{team.id}"
      expect(response).to be_success

      # TODO Swap these specs when there are full teams
      # expect(json_body["league_players"].size).to eq(team.roster_slots.size)
      expect(json_body["league_players"]).to be

      expect(json_body["league_players"][0]["id"]).to be
      expect(json_body["league_players"][0]["first_name"]).to be
      expect(json_body["league_players"][0]["last_name"]).to be
    end

    it "includes league_positions" do
      get "/api/v1/teams/#{team.id}"
      expect(response).to be_success
      expect(json_body["league_positions"].size).to eq(team.roster_slots.map(&:league_position_id).uniq.size)
      expect(json_body["league_positions"][0]["id"]).to be
      expect(json_body["league_positions"][0]["title"]).to be
    end
  end

  describe "INDEX" do
    let(:league) { League.find_by!({ title: "BadCelebs" }) }

    it "includes base team attributes" do
      get "/api/v1/teams?league_id=#{league.id}"
      expect(response).to be_success
      expect(json_body["teams"]).to be
      expect(json_body["teams"]).to be
    end
  end

  describe "PUT ROSTER" do
    let(:league) { LeagueTemplate.find_by!({ title: "Bad Celebrity" }).create_league!("Foo League") }
    let(:team) { league.teams.create!({ title: "Team" }) }

    it "includes base team attributes" do
      player1, player2 = team.league.players.shuffle.first(2)
      data = {
        team: {
          roster_slots: [
            { league_position_id: player1.league_position.id, league_player_id: player1.id },
            { league_position_id: player2.league_position.id, league_player_id: player2.id }
          ]
        }
      }
      expect do
        put "/api/v1/teams/#{team.id}/roster_slots", data
      end.to change(RosterSlot, :count).by(2)

      expect(response).to be_success
    end
  end
end
