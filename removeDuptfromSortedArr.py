class Solution:
    def removeDuplicates(self, nums: List[int]) -> int:
        count_dict = {}
        j = extra = 0

        for i in range(len(nums)):

            if nums[i] in count_dict:
                count_dict[nums[i]] += 1
            else:
                count_dict[nums[i]] = 1 
            

            if count_dict[nums[i]] <= 2:
                
                if count_dict[nums[j]] > 2:
                    nums[i], nums[j] = nums[j], nums[i]
                
                j += 1
            
            else:
                extra += 1
        
        return len(nums) - extra
