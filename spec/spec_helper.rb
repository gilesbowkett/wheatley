# if you read the specs carefully you will notice that neither spec currently
# requires this file at all. however, when developing this initially, I found
# this method incredibly useful. it uses the awesome_print gem. fixing specs
# against trees is pretty fucking painful without it.

def log_tree(tree)
  puts tree.ai
end
