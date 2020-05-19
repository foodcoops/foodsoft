 #!/usr/bin/env bash
export DATABASE_URL=postgres://food-coop:food-coop@localhost/food-coop
export SECRET_KEY_BASE=0f3d07c50c0e7c88aae9d468e7f9481473ee32deac037ef5aebbc2995f66
#export SHARED_DATABASE_URL=postgres://postgres:keepit3@localhost/food-prices
#export SHARED_DATABASE_URL=postgres://food-coop:Jusliek3oca@awa.intellecti.ca:5432/food-coop-prices
#export SHARED_DATABASE_URL=postgresql://food-coop:youcannoteatdata@postgres.intellecti.ca/food-coop-prices
export SHARED_DATABASE_URL=postgresql://food-coop:food-coop@localhost/food-prices
export RAILS_FORCE_SSL=false
export SMTP_PORT=1025
export SMTP_DOMAIN=localhost
export SMTP_ADDRESS=localhost
export REDIS_URL=redis://127.0.0.1:6379/

