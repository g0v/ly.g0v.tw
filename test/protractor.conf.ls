exports.config = do
  seleniumAddress: 'http://localhost:4444/wd/hub'

  capabilities:
    browserName: 'chrome'

  specs:
    'e2e/app/*.ls'
    ...
