class Solution:
    def waysToSplitArray(self, nums: List[int]) -> int:
        total_sum = sum(nums)
        res = curr_sum = 0
        for i in range(len(nums) - 1):
            curr_sum += nums[i]
            if total_sum - curr_sum <= curr_sum:
                res += 1
        
        return res
