# Dependencies
Repository for packaging OpenRCT2 library dependencies together.

## Releasing

Doing a new Dependencies release is straight forward:
1. Make sure you have a passing/green commit
2. `git tag -a vXX COMMIT_HASH`
3. Add the messages you want to the tag, it might be good to include the changes it's encompassing (like the name of the PRs)
4. `git push origin vXX`
5. The workflow will automatically start, post a new release and upload the artifacts there once it finishes
6. Check back later to see whether the workflow ran successfully
