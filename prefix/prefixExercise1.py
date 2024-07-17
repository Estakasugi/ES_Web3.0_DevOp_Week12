def testPrefix(nums, queries, limit):
    res = []
    prefix = [nums[0]]

    # pre-processing prefix
    for i in range(1,len(nums)):
        prefix.append(nums[i] + prefix[len(prefix)-1])
    
    #main logic
    for query in queries:
        res.append( (prefix[query[1]] - prefix[query[0]] + nums[query[0]]) < limit )
    
    return res


ans = testPrefix(nums = [1, 6, 3, 2, 7, 2], queries = [[0, 3], [2, 5], [2, 4]], limit = 13)
print(ans)